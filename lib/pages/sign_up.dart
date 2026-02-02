import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'login.dart'; // Make sure LoginPage exists in this path

class SignUpPage extends StatefulWidget {
  final String role; // 🚨 Role passed from selection page

  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? uploadedFileName;
  bool isPasswordHidden = true;

  // PASSWORD RULE: min 8 chars, uppercase, lowercase, number, special char
  final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        uploadedFileName = result.files.single.name;
      });
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      if (uploadedFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload verification document")),
        );
        return;
      }

      // SUCCESS → GO TO LOGIN PAGE
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ROLE + HEADER
                Text(
                  "${widget.role} Sign Up",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // FULL NAME
                buildTextField(
                  controller: fullNameController,
                  label: "Full Name",
                  validator: (value) => value!.isEmpty ? "Full name is required" : null,
                ),

                // EMAIL
                buildTextField(
                  controller: emailController,
                  label: "Email ID",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return "Email is required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                // MOBILE NUMBER
                buildTextField(
                  controller: mobileController,
                  label: "Mobile Number",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Mobile number is required";
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return "Enter valid 10 digit number";
                    }
                    return null;
                  },
                ),

                // PASSWORD
                buildTextField(
                  controller: passwordController,
                  label: "Password",
                  obscureText: isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Password is required";
                    if (!passwordRegex.hasMatch(value)) {
                      return "Min 8 chars, upper, lower, number & special char";
                    }
                    return null;
                  },
                ),

                // CONFIRM PASSWORD
                buildTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  obscureText: true,
                  
                  validator: (value) {
                    if (value!.isEmpty) return "Confirm your password";
                    if (value != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // DOCUMENT UPLOAD
                GestureDetector(
                  onTap: pickDocument,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.upload_file, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            uploadedFileName ?? "Upload Verification Document",
                            style: TextStyle(
                              color: uploadedFileName == null ? Colors.grey : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // CREATE ACCOUNT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF22C55E)),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
