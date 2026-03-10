import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String role;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? doc1;
  final String? doc2;

  const OTPVerificationPage({
    super.key,
    required this.verificationId,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.doc1,
    this.doc2,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  Future<void> _completeAuth() async {
    if (_otpController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6 digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // Create phone credential
      PhoneAuthCredential phoneCred = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Create email account
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Link phone
      await userCred.user!.linkWithCredential(phoneCred);

      String uid = userCred.user!.uid;

      // Decide collection
      String collection = widget.role == "Ambulance Driver"
          ? "ambulance_drivers"
          : "traffic_police";

      Map<String, dynamic> data = {
        "uid": uid,
        "name": widget.name,
        "email": widget.email,
        "phone": widget.phone,
        "role": widget.role,
        "status": "pending_approval",
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Add documents
      if (widget.role == "Ambulance Driver") {
        data["driving_license"] = widget.doc1;
        data["ambulance_id"] = widget.doc2;
      } else {
        data["police_id"] = widget.doc1;
      }

      await FirebaseFirestore.instance.collection(collection).doc(uid).set(data);

      await userCred.user!.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

      Navigator.pushNamedAndRemoveUntil(context, "/dashboard", (route) => false);

    } on FirebaseAuthException catch (e) {
      String msg = "Authentication failed";

      if (e.code == 'invalid-verification-code') msg = "Wrong OTP";
      if (e.code == 'email-already-in-use') msg = "Email already exists";
      if (e.code == 'credential-already-in-use') msg = "Phone already used";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock, size: 80, color: Color(0xFF22C55E)),
            const SizedBox(height: 20),
            Text(
              "Code sent to ${widget.phone}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 32, letterSpacing: 8),
              decoration: const InputDecoration(counterText: ""),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _completeAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verify & Create Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}