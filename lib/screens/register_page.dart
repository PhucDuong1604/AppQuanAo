import 'package:flutter/material.dart';

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
  final _dobController = TextEditingController();
  String _selectedGender = 'Nam';

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
                decoration: const InputDecoration(
                  hintText: "Nhập số điện thoại tại đây",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
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
                validator: (value) =>
                    value!.isEmpty ? "Vui lòng nhập email" : null,
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
                      _dobController.text =
                          "${date.day}/${date.month}/${date.year}";
                    });
                  }
                },
                decoration: const InputDecoration(
                  hintText: "Thông tin này cần bắt buộc",
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đăng ký thành công!")),
                      );
                    }
                    
                 
                  },
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
