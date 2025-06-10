import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appquanao/screens/address_list_screen.dart';
import 'package:appquanao/screens/order_list_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dữ liệu giả định của người dùng
  String _fullName = 'Dương Trọng Phúc';
  String _email = 'duongphuc1125@gmail.com';
  String _phoneNumber = '+84706398104';
  DateTime? _dateOfBirth = DateTime(2004, 6, 1); // 01/06/2004
  String? _gender = 'Nam'; // Giá trị ban đầu cho Dropdown

  final TextEditingController _dateOfBirthController = TextEditingController();

  // Biến để theo dõi tab đang được chọn
  int _selectedIndex = 0; // 0: Thông tin cá nhân, 1: Địa chỉ, v.v.
  final List<String> _appBarTabs = [
    'Thông tin cá nhân',
    'Địa chỉ',
    'Đơn hàng',
  ];

  @override
  void initState() {
    super.initState();
    if (_dateOfBirth != null) {
      _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(_dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Hàm để xây dựng nội dung Body dựa trên tab được chọn
  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildPersonalInfoContent();
      case 1:
        return const AddressListScreen();
      case 2: // Index 2 cho Đơn hàng
        return OrderListScreen(); // Hiển thị màn hình danh sách đơn hàng
      case 3:
        return const Center(child: Text('Nội dung Membership sẽ ở đây.'));
      case 4:
        return const Center(child: Text('Nội dung Wishlist sẽ ở đây.'));
      default:
        return const Center(child: Text('Nội dung không xác định.'));
    }
  }

  // Hàm tách riêng phần nội dung thông tin cá nhân (giữ nguyên)
  Widget _buildPersonalInfoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần thông tin Avatar và Tên/Email
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 70,
                        color: Colors.grey[600],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatisticItem('0', 'Đơn hàng\nGiao thành công'),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatisticItem('0', 'Voucher'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Các trường thông tin chi tiết
          _buildInputField('Họ và tên', _fullName, (value) => _fullName = value),
          _buildInputField('Email', _email, (value) => _email = value, readOnly: true, keyboardType: TextInputType.emailAddress),
          _buildInputField('Số điện thoại', _phoneNumber, (value) => _phoneNumber = value, keyboardType: TextInputType.phone),

          // Ngày sinh
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ngày sinh', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Giới tính
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giới tính', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                items: <String>['Nam', 'Nữ', 'Khác']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
              ),
              const SizedBox(height: 30),
            ],
          ),

          // Nút Đăng Xuất và Đổi Thưởng
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý đăng xuất
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang đăng xuất...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Màu nền đen
                    foregroundColor: Colors.white, // Màu chữ trắng
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đăng Xuất',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nút Đổi Thưởng được thêm lại
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_appBarTabs.length, (index) {
                return _buildAppBarTab(
                  _appBarTabs[index],
                  _selectedIndex == index,
                  () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              }),
            ),
          ),
        ),
      ),
      body: _buildBodyContent(), // Hiển thị nội dung động
    );
  }

  // Sửa đổi hàm này để nhận thêm onTap callback
  Widget _buildAppBarTab(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector( // Sử dụng GestureDetector để xử lý tap
        onTap: onTap,
        child: Container(
          decoration: isSelected
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2.0),
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label,
      String initialValue,
      ValueChanged<String> onChanged, {
        bool readOnly = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatisticItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}