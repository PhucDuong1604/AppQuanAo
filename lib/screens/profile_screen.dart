import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:appquanao/screens/order_list_screen.dart'; // Đảm bảo import này đúng
import 'package:appquanao/models/user_session.dart'; // Import UserSession, and User model
import 'package:appquanao/screens/login_screen.dart'; // Import LoginPage để điều hướng sau khi đăng xuất

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Biến để lưu trữ dữ liệu người dùng từ UserSession (chỉ để dễ đọc trong code)
  // Consumer sẽ là nơi chính để lấy dữ liệu reactive.
  User? _currentUser;

  // Controllers cho các trường nhập liệu
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  DateTime? _dateOfBirth;

  // Biến để giữ giá trị giới tính đã chuẩn hóa cho DropdownButtonFormField
  String? _genderValueForDropdown;

  // Biến để theo dõi tab đang được chọn
  int _selectedIndex = 0;
  final List<String> _appBarTabs = [
    'Thông tin cá nhân',
    'Đơn hàng',
  ];

  // Store the UserSession instance so we can add/remove listener
  UserSession? _userSessionInstance;

  @override
  void initState() {
    super.initState();
  }

  // Hàm khởi tạo và cập nhật các controllers từ UserSession
  void _updateControllersFromUserSession() {
    if (_userSessionInstance == null) {
      print("Lỗi: _userSessionInstance là null trong _updateControllersFromUserSession.");
      return;
    }

    final User? fetchedUser = _userSessionInstance!.currentUser;

    // Chỉ cập nhật state và controllers nếu dữ liệu thực sự khác
    if (_currentUser != fetchedUser) {
      _currentUser = fetchedUser;

      if (_currentUser != null) {
        // Populate fields
        _fullNameController.text = _currentUser!.hoTen ?? '';
        _emailController.text = _currentUser!.email;
        _phoneNumberController.text = _currentUser!.soDienThoai ?? '';

        _dateOfBirth = _currentUser!.ngaySinh;
        if (_dateOfBirth != null) {
          _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(_dateOfBirth!);
        } else {
          _dateOfBirthController.text = '';
        }

        String? genderFromUser = _currentUser!.gioiTinh?.toLowerCase();
        if (['nam', 'nu', 'khác'].contains(genderFromUser)) { // Thêm 'khác' vào đây nếu cần
          _genderValueForDropdown = genderFromUser;
        } else {
          _genderValueForDropdown = null; // Đặt null nếu giá trị không hợp lệ
        }
      } else {
        // Nếu không có người dùng, xóa dữ liệu trong controllers và điều hướng về trang đăng nhập
        _fullNameController.clear();
        _emailController.clear();
        _phoneNumberController.clear();
        _dateOfBirthController.clear();
        _genderValueForDropdown = null;
        _dateOfBirth = null;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          }
        });
      }
      if (mounted) {
        setState(() {}); // Cập nhật UI
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final newUserSessionInstance = Provider.of<UserSession>(context, listen: false);
      if (newUserSessionInstance != _userSessionInstance) {
        _userSessionInstance?.removeListener(_updateControllersFromUserSession);
        _userSessionInstance = newUserSessionInstance;
        _userSessionInstance!.addListener(_updateControllersFromUserSession);
        _updateControllersFromUserSession();
      }
    } on ProviderNotFoundException catch (e) {
      print("Lỗi ProviderNotFoundException trong didChangeDependencies: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      });
    } catch (e) {
      print("Lỗi không xác định khi thiết lập Provider trong didChangeDependencies: $e");
    }
  }

  @override
  void dispose() {
    _userSessionInstance?.removeListener(_updateControllersFromUserSession);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
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
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(_dateOfBirth!);
        Provider.of<UserSession>(context, listen: false).updateNgaySinh(picked);
      });
    }
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildPersonalInfoContent();
      case 1:
        return OrderListScreen(); // Hiển thị màn hình đơn hàng
      default:
        return const Center(child: Text('Nội dung không xác định.'));
    }
  }

  Widget _buildPersonalInfoContent() {
    return Consumer<UserSession>(
      builder: (context, userSession, child) {
        final User? currentUser = userSession.currentUser;

        if (currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cập nhật controllers nếu dữ liệu từ Provider đã thay đổi
        if (_fullNameController.text != (currentUser.hoTen ?? '')) {
          _fullNameController.text = currentUser.hoTen ?? '';
        }
        if (_emailController.text != currentUser.email) {
          _emailController.text = currentUser.email;
        }
        if (_phoneNumberController.text != (currentUser.soDienThoai ?? '')) {
          _phoneNumberController.text = currentUser.soDienThoai ?? '';
        }

        final newDateOfBirth = currentUser.ngaySinh;
        if (_dateOfBirth != newDateOfBirth) {
          _dateOfBirth = newDateOfBirth;
          _dateOfBirthController.text = _dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
              : '';
        }

        final newGender = currentUser.gioiTinh?.toLowerCase();
        // Cần đảm bảo rằng giá trị 'khác' cũng được xử lý nếu API trả về
        if (_genderValueForDropdown != newGender && ['nam', 'nu', 'khác'].contains(newGender)) {
          _genderValueForDropdown = newGender;
        }


        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      currentUser.hoTen ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentUser.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Thêm khoảng cách sau phần ảnh đại diện

              _buildTextFormField(
                label: 'Họ và tên',
                controller: _fullNameController,
                onChanged: (value) {
                  userSession.updateHoTen(value);
                },
              ),
              _buildTextFormField(
                label: 'Email',
                controller: _emailController,
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextFormField(
                label: 'Số điện thoại',
                controller: _phoneNumberController,
                onChanged: (value) {
                  userSession.updateSoDienThoai(value);
                },
                keyboardType: TextInputType.phone,
              ),

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
                      hintText: 'Chọn ngày sinh',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Giới tính', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _genderValueForDropdown,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      hintText: 'Chọn giới tính',
                    ),
                    items: <String>['nam', 'nu', 'khác'] // Đảm bảo 'khác' có trong danh sách nếu API trả về
                        .map<DropdownMenuItem<String>>((String itemValue) {
                      String displayText = '';
                      if (itemValue == 'nam') {
                        displayText = 'Nam';
                      } else if (itemValue == 'nu') {
                        displayText = 'Nữ';
                      } else if (itemValue == 'khác') {
                        displayText = 'Khác';
                      }
                      return DropdownMenuItem<String>(
                        value: itemValue,
                        child: Text(displayText),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _genderValueForDropdown = newValue;
                      });
                      userSession.updateGioiTinh(newValue);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        userSession.clearUser();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã đăng xuất.')),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tài khoản của tôi', style: TextStyle(color: Colors.black)), // Đổi tiêu đề
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
      body: _buildBodyContent(),
    );
  }

  Widget _buildAppBarTab(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
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

  Widget _buildTextFormField({
    required String label,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
}