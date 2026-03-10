import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:file_picker/file_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'registration_success_page.dart';

class SignUpPage extends StatefulWidget {
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  String selectedCountryCode = "+91";
  String? doc1Name;
  String? doc2Name;

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirm = true;

  // OTP variables
  String? verificationId;
  bool otpSent = false;
  bool isPhoneVerified = false;

  // Password rules
  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasNumber = false;
  bool hasSpecial = false;

  final RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

  void checkPassword(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      hasLower = RegExp(r'[a-z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  bool get isPasswordValid =>
      hasMinLength && hasUpper && hasLower && hasNumber && hasSpecial;

  Future<void> pickDoc1() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => doc1Name = result.files.single.name);
    }
  }

  Future<void> pickDoc2() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => doc2Name = result.files.single.name);
    }
  }

  // ---------------- FIREBASE ACTIONS ----------------

  Future<void> sendOTP(String phoneNumber) async {
    setState(() => isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            isPhoneVerified = true;
            otpSent = false;
            isLoading = false;
          });
        },
        verificationFailed: (e) {
          setState(() => isLoading = false);
          _showError(e.message ?? "Verification failed");
        },
        codeSent: (verId, _) {
          setState(() {
            verificationId = verId;
            otpSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (verId) => verificationId = verId,
      );
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Error sending OTP");
    }
  }

  Future<void> verifyOTP() async {
    if (verificationId == null) return;
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      setState(() {
        isPhoneVerified = true;
        otpSent = false;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Invalid OTP");
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isPhoneVerified) {
      _showError("Please verify phone number first");
      return;
    }
    if (!isPasswordValid) {
      _showError("Password does not meet requirements");
      return;
    }

    // Role-specific document validation
    bool isDriver = widget.role == "Ambulance Driver";
    if (isDriver) {
      if (doc1Name == null || doc2Name == null) {
        _showError("Upload both documents");
        return;
      }
    } else {
      if (doc1Name == null) {
        _showError("Upload Police ID");
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      // 1. Create User in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Prepare Data Map
      Map<String, dynamic> userData = {
        "uid": uid,
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": "$selectedCountryCode${mobileController.text.trim()}",
        "role": widget.role,
        "status": "pending", // For admin approval logic
        "createdAt": FieldValue.serverTimestamp(),
        "document1": doc1Name,
      };

      if (isDriver) {
        userData["document2"] = doc2Name;
      }

      // 3. Save to Collection based on Role
      // "drivers" for Ambulance Driver, "police" for Police Officer
      String collectionName = isDriver ? "drivers" : "police";
      
      await _firestore.collection(collectionName).doc(uid).set(userData);

      // 4. Navigate to success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationSuccessPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registration failed");
    } catch (e) {
      _showError("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------------- UI HELPERS ----------------

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget rule(String text, bool valid) {
    return Row(
      children: [
        Icon(valid ? Icons.check_circle : Icons.cancel,
            color: valid ? Colors.green : Colors.grey, size: 18),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget docTile(String title, String? fileName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(fileName ?? title,
                  style: const TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDriver = widget.role == "Ambulance Driver";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.role} Sign Up",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                buildField(fullNameController, "Full Name"),
                buildField(emailController, "Email", validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  if (!emailRegex.hasMatch(v)) return "Enter valid email";
                  return null;
                }),
                Column(
                  children: [
                    TextFormField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.length < 7 ? "Enter valid number" : null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        prefixIcon: CountryCodePicker(
                          initialSelection: 'IN',
                          textStyle: const TextStyle(color: Colors.white),
                          onChanged: (c) => selectedCountryCode = c.dialCode!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!otpSent && !isPhoneVerified)
                      ElevatedButton(
                        onPressed: () {
                          String raw = mobileController.text.trim();
                          if (raw.startsWith('0')) raw = raw.substring(1);
                          sendOTP("$selectedCountryCode$raw");
                        },
                        child: const Text("Verify Phone"),
                      ),
                    if (otpSent) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Enter OTP"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: verifyOTP, child: const Text("Verify OTP")),
                    ],
                    if (isPhoneVerified)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 6),
                          Text("Phone Verified", style: TextStyle(color: Colors.green)),
                        ]),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  onChanged: checkPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                rule("Minimum 8 characters", hasMinLength),
                rule("Uppercase letter", hasUpper),
                rule("Lowercase letter", hasLower),
                rule("Number", hasNumber),
                rule("Special character", hasSpecial),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirm,
                  validator: (v) => v != passwordController.text ? "Passwords do not match" : null,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(hideConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => hideConfirm = !hideConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                docTile(isDriver ? "Upload Driving License" : "Upload Police ID", doc1Name, pickDoc1),
                if (isDriver) docTile("Upload Ambulance/Hospital ID", doc2Name, pickDoc2),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitForm, // Updated to call the logic
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Register", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField(TextEditingController c, String label, {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: c,
        validator: validator ?? (v) => v!.isEmpty ? "Required" : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}