import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  // 🔥 GIỮ NGUYÊN LOGIC ĐĂNG NHẬP CỦA HẢI ANH
  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Please enter Email and Password");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      // Nhảy thẳng vào Home sau khi login thành công
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "Login failed ❌";
      if (e.code == 'user-not-found')
        message = "No user found with this email.";
      if (e.code == 'wrong-password') message = "Wrong password. Try again!";
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", isError: true);
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 ĐỒNG BỘ MÀU HỒNG PASTEL VỚI TRANG REGISTER
    final primaryColor = Colors.pink.shade300;
    final pastelPinkBackground = const Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: pastelPinkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            // 🔥 HỘP THU GỌN (MAX 450px)
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome Back👏",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Login to continue your journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email Field
                _buildTextField(
                  controller: emailController,
                  labelText: "Email Address",
                  prefixIcon: Icons.email_outlined,
                  fillColor: Colors.pink.shade50.withOpacity(0.3),
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 15),

                // Password Field
                _buildTextField(
                  controller: passwordController,
                  labelText: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_isPasswordVisible,
                  fillColor: Colors.pink.shade50.withOpacity(0.3),
                  primaryColor: primaryColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: primaryColor,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                isLoading
                    ? CircularProgressIndicator(color: primaryColor)
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "LOG IN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 25),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    "Not a member? Register now",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
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

  // --- HELPER WIDGET ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Color primaryColor,
    bool obscureText = false,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(prefixIcon, size: 20, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
