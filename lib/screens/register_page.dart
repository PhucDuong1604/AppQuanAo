import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import thư viện http
import 'dart:convert'; // Import để làm việc với JSON
import 'package:intl/intl.dart'; // Import để định dạng ngày tháng
import 'package:appquanao/screens/login_screen.dart'; // Thay thế bằng đường dẫn đúng của bạn

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _matkhauController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Nam'; // Giá trị mặc định

  @override
  void dispose() {
    // Giải phóng controllers khi widget bị hủy
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _matkhauController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Hàm để gửi dữ liệu đăng ký đến API
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Định dạng ngày sinh sangYYYY-MM-DD
      String? formattedDob;
      if (_dobController.text.isNotEmpty) {
        try {
          // Parse DD/MM/YYYY to DateTime
          DateTime dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
          formattedDob = DateFormat('yyyy-MM-dd').format(dob);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ngày sinh không hợp lệ.")),
          );
          return;
        }
      }

      // Chuẩn bị dữ liệu để gửi đi
      final Map<String, dynamic> data = {
        'action': 'register', // Xác định hành động là 'register'
        'email': _emailController.text, // Email
        'ho_ten': _nameController.text, // Họ và tên
        'so_dien_thoai': _phoneController.text, // Số điện thoại
        'mat_khau': _matkhauController.text, // Số điện thoại
        'ngay_sinh': formattedDob, // Ngày sinh đã định dạng
        'gioi_tinh': _selectedGender == 'Nam' ? 'nam' : 'nu', // Giới tính (chuyển sang 'nam'/'nu')
        // 'dia_chi': 'địa chỉ của người dùng', // Bạn có thể thêm trường địa chỉ nếu có
      };

      // URL của API PHP
      // === SỬA ĐỔI QUAN TRỌNG TẠI ĐÂY ===
      // Nếu chạy trên Android Emulator: sử dụng '10.0.2.2'
      // Nếu chạy trên thiết bị Android vật lý: thay 'localhost' bằng địa chỉ IP của máy tính bạn (ví dụ: '192.168.1.X')
      final Uri uri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/taikhoan/themtaikhoan.php'); 
      // Hoặc nếu bạn đang chạy trên thiết bị vật lý, hãy thay thế bằng địa chỉ IP của máy tính bạn:
      // final Uri uri = Uri.parse('http://YOUR_LOCAL_IP_ADDRESS/apiAppQuanAo/api/auth.php');
      // Ví dụ: final Uri uri = Uri.parse('http://192.168.1.100/apiAppQuanAo/api/auth.php');
      // ======================================

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
            // Điều hướng về trang đăng nhập và thay thế màn hình hiện tại
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()), // Đảm bảo LoginPage được định nghĩa và import
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'])),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi server: ${response.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Họ và tên"),
              const SizedBox(height: 5),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Nhập họ và tên tại đây",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập họ và tên" : null,
              ),
              const SizedBox(height: 15),

              const Text("Số điện thoại"),
              const SizedBox(height: 5),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Thêm ràng buộc độ dài tối đa là 10 ký tự
                decoration: const InputDecoration(
                  hintText: "Nhập số điện thoại tại đây",
                  border: OutlineInputBorder(),
                  counterText: "", // Ẩn bộ đếm ký tự
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập số điện thoại";
                  }
                  // Ràng buộc: bắt đầu bằng số 0 và đúng 10 số
                  if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
                    return "Số điện thoại phải bắt đầu bằng số 0 và có 10 chữ số";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              const Text("Email"),
              const SizedBox(height: 5),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Thông tin này cần bắt buộc",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập email";
                  }
                  // Ràng buộc: đúng định dạng email
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    return "Email không đúng định dạng";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              const Text("Mật khẩu"),
              const SizedBox(height: 5),
              TextFormField(
                controller: _matkhauController,
                obscureText: true, // Để ẩn mật khẩu
                decoration: const InputDecoration(
                  hintText: "Thông tin này cần bắt buộc",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập mật khẩu" : null,
              ),
              const SizedBox(height: 15),

              const Text("Ngày sinh"),
              const SizedBox(height: 5),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      // Định dạng ngày hiển thị DD/MM/YYYY
                      _dobController.text = DateFormat('dd/MM/yyyy').format(date);
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Chọn ngày sinh", // Đổi hintText cho rõ ràng
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng chọn ngày sinh" : null,
              ),
              const SizedBox(height: 15),

              const Text("Giới tính"),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: ['Nam', 'Nữ']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerUser, // Gọi hàm đăng ký khi nhấn nút
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Đăng ký"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
