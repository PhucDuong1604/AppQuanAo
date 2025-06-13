import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // Import Provider

import 'package:appquanao/screens/home_screen.dart'; // Màn hình chính
import 'package:appquanao/screens/forgot_password_screen.dart';
import 'package:appquanao/models/user_session.dart'; // Import UserSession

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    final String matKhau = _passwordController.text;

    if (email.isEmpty || matKhau.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu.")),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'action': 'login',
      'email': email,
      'mat_khau': matKhau,
    };

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

          // --- PHẦN CẬP NHẬT QUAN TRỌNG NHẤT Ở ĐÂY ---
          // Thay đổi từ 'user' sang 'data' để khớp với API PHP
          final userData = responseData['data']; // <<< THAY ĐỔI DÒNG NÀY

          if (userData != null) {
            // Log dữ liệu nhận được từ API để debug
            print('Dữ liệu người dùng từ API: $userData');

            final User loggedInUser = User(
              // Đảm bảo các key sau khớp chính xác với key trong JSON của PHP
              // Ví dụ: PHP dùng 'id', 'ho_ten', 'so_dien_thoai', 'gioi_tinh', 'trang_thai'
              id: userData['id'] , // Chú ý ép kiểu int nếu cần
              email: userData['email'],
              hoTen: userData['ho_ten'],
              soDienThoai: userData['so_dien_thoai'],
              // Giới tính đang là string, bạn cần đảm bảo hàm tạo User chấp nhận string
              gioiTinh: userData['gioi_tinh'],
              trangThai: userData['trang_thai'] == 1 || userData['trang_thai'] == true, // Trạng thái có thể là int (1/0) hoặc boolean
              // Ngày sinh có thể là null, và không có trong response hiện tại của bạn.
              // Nếu bạn cần ngày sinh, bạn phải thêm nó vào câu SELECT trong PHP và vào response JSON.
              // Ví dụ: ngaySinh: userData['ngay_sinh'] != null && userData['ngay_sinh'] != ''
              //             ? DateTime.tryParse(userData['ngay_sinh'])
              //             : null,
            );

            // Lấy instance UserSession và cập nhật người dùng
            Provider.of<UserSession>(context, listen: false).setUser(loggedInUser);

            // Điều hướng đến màn hình chính hoặc ProfileScreen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
            );

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Dữ liệu người dùng không được trả về từ API hoặc không đúng định dạng.")),
            );
            print('Lỗi: Key "data" không chứa dữ liệu người dùng hợp lệ.');
          }
          // --- KẾT THÚC PHẦN CẬP NHẬT QUAN TRỌNG ---

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi server: ${response.statusCode}. Vui lòng thử lại sau.")),
        );
        print('Lỗi API Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối: Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối mạng hoặc địa chỉ API.")),
      );
      print("Lỗi kết nối chi tiết: $e");
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
              Image.asset(
                'images/login.jpg',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Mật khẩu", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Mật khẩu",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _loginUser,
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