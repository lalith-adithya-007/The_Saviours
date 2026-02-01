import 'package:flutter/material.dart';

// Import target pages
import 'selection_page.dart';
import 'dashboard.dart';
import 'forgot_password.dart'; // 👈 Make sure you create this page

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFF000000);
    const Color cardBg = Color(0xFF1E1E1E);
    const Color inputBg = Color(0xFF121212);
    const Color brandGreen = Color(0xFF22C55E);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: brandGreen,
                  child: Icon(Icons.login_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Welcome Back",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Sign in to your account",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 32),

                _buildInputLabel("Email ID or Phone Number"),
                _buildTextField(inputBg, "Enter your email or phone"),
                const SizedBox(height: 20),

                _buildInputLabel("Password"),
                _buildTextField(inputBg, "Enter your password", isPassword: true),

                // --------- Forgot Password ---------
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // LOGIN → Dashboard
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[800])),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[800])),
                    ],
                  ),
                ),

                // SIGN UP → Role Selection
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoleSelectionPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[800]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static Widget _buildTextField(
    Color bgColor,
    String hint, {
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: bgColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF22C55E)),
        ),
      ),
    );
  }
}
