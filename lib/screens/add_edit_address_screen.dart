// lib/screens/add_edit_address_screen.dart
import 'package:flutter/material.dart';
import 'package:appquanao/models/address.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address; // Địa chỉ hiện có (nếu đang chỉnh sửa)

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _districtController = TextEditingController(text: widget.address?.district ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        name: _nameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        district: _districtController.text,
        city: _cityController.text,
        isDefault: _isDefault,
      );
      Navigator.pop(context, newAddress); // Trả về địa chỉ mới/đã chỉnh sửa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                controller: _nameController,
                label: 'Tên người nhận',
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              _buildInputField(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              _buildInputField(
                controller: _streetController,
                label: 'Số nhà, tên đường',
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số nhà, tên đường' : null,
              ),
              _buildInputField(
                controller: _districtController,
                label: 'Quận/Huyện',
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập Quận/Huyện' : null,
              ),
              _buildInputField(
                controller: _cityController,
                label: 'Tỉnh/Thành phố',
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập Tỉnh/Thành phố' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDefault = value!;
                      });
                    },
                  ),
                  const Text('Đặt làm địa chỉ mặc định'),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(widget.address == null ? 'Thêm địa chỉ' : 'Lưu địa chỉ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}