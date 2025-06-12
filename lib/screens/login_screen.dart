import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import thư viện http
import 'dart:convert'; // Import để làm việc với JSON

import 'package:appquanao/screens/home_screen.dart';
import 'package:appquanao/screens/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Đã đổi tên controller cho khớp với PHP API (mat_khau)
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm để gửi dữ liệu đăng nhập đến API
  Future<void> _loginUser() async {
    final String email = _emailController.text;
    final String matKhau = _passwordController.text; // Lấy mật khẩu từ controller

    if (email.isEmpty || matKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu.")),
      );
      return;
    }

    // Chuẩn bị dữ liệu để gửi đi
    final Map<String, dynamic> data = {
      'action': 'login', // Xác định hành động là 'login'
      'email': email,
      'mat_khau': matKhau, // Đảm bảo tên trường khớp với API PHP
    };

    // URL của API PHP
    // Thay thế bằng địa chỉ IP của máy tính của bạn nếu đang chạy trên thiết bị vật lý
    // hoặc '10.0.2.2' nếu chạy trên emulator Android
    final Uri uri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/taikhoan/login.php'); 

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
          // Điều hướng về trang chủ và thay thế màn hình đăng nhập
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()), // Đảm bảo HomePage được định nghĩa và import
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi server: ${response.statusCode}. Vui lòng thử lại sau.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API.")),
      );
      print("Lỗi kết nối chi tiết: $e"); // In lỗi ra console để debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Ảnh banner đầu trang
              Image.asset(
                'images/login.jpg', // Đảm bảo bạn có file này trong assets/images/
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              // Email input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress, // Thêm keyboard type
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bo tròn góc
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Tăng padding để đẹp hơn
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password input
                    const Text("Mật khẩu", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Mật khẩu",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0), // Bo tròn góc
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Tăng padding
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          color: Colors.blue, // Đổi màu để dễ nhận biết là link
                          // decoration: TextDecoration.underline, // Có thể thêm gạch chân
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Nút đăng nhập
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Bo tròn góc nút
                    ),
                  ),
                  onPressed: _loginUser, // Gọi hàm đăng nhập khi nhấn nút
                  child: const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                ),
              ),


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
