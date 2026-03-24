import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;

  void register() async {
    // 1. Kiểm tra đầu vào
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Please fill in Email and Password", isError: true);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      print("🚀 Bắt đầu tạo tài khoản Auth...");
      // 2. Tạo tài khoản trên Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      print("✅ Đã tạo Auth UID: ${userCredential.user!.uid}");

      // 3. 🔥 TỰ ĐỘNG LƯU VÀO FIRESTORE (Phần quan trọng nhất nè!)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid) // Dùng UID làm ID của Document luôn
          .set({
            'email': emailController.text.trim(),
            'role': 'user', // Mặc định đăng ký mới là khách (User)
            'createdAt': DateTime.now(),
          });

      print("📦 Đã lưu thông tin vào Firestore!");

      if (!mounted) return;

      _showSnackBar("🎉 Registration successful!", isSuccess: true);

      // 4. Vào thẳng trang Home
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed ❌";
      if (e.code == 'email-already-in-use')
        message = "This email is already in use!";
      if (e.code == 'weak-password') message = "Password is too weak!";
      _showSnackBar(message, isError: true);
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      _showSnackBar("Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : (isError ? Colors.red : Colors.grey),
      ),
    );
  }
  void _registerUser() async {
    print("1. Bắt đầu chạy hàm Register...");

    // Kiểm tra xem các ô nhập liệu có bị trống không
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      print("2. LỖI: Email hoặc Pass đang trống không!");
      return;
    }

    try {
      print("3. Đang gửi dữ liệu lên Firebase...");
      // Code Firebase của bạn ở đây...
    } catch (e) {
      print("4. CÓ LỖI XẢY RA: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 MÀU HỒNG PASTEL (NHẠT VÀ MỊN)
    final primaryColor = Colors.pink.shade300; // Màu nút hồng vừa phải
    final pastelPinkBackground = const Color(0xFFFFF0F5); // Lavender Blush (Hồng cực nhạt)

    return Scaffold(
      backgroundColor: pastelPinkBackground, // Nền hồng Pastel toàn màn hình
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Container(
            // 🔥 HỘP ĐĂNG KÝ THU GỌN (MAX 450px cho Web)
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bỏ logo hình ảnh, chỉ dùng Icon đơn giản
                const Text(
                  "Sign Up 🥞",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create your account to start ordering",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 35),

                _buildTextField(
                  controller: emailController,
                  labelText: "Email Address",
                  prefixIcon: Icons.email_outlined,
                  fillColor: Colors.pink.shade50.withOpacity(0.3),
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 15),

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
                const SizedBox(height: 15),

                _buildTextField(
                  controller: confirmPasswordController,
                  labelText: "Confirm Password",
                  prefixIcon: Icons.check_circle_outline,
                  obscureText: !_isPasswordVisible,
                  fillColor: Colors.pink.shade50.withOpacity(0.3),
                  primaryColor: primaryColor,
                ),

                const SizedBox(height: 35),

                isLoading
                    ? CircularProgressIndicator(color: primaryColor)
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0, // Nút phẳng cho đúng chất Pastel
                          ),
                          child: const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Log In",
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
