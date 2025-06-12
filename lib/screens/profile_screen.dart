import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:appquanao/screens/address_list_screen.dart';
import 'package:appquanao/screens/order_list_screen.dart'; 
import 'package:appquanao/models/user_session.dart'; // Import UserSession
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
  final TextEditingController _tenDangNhapController = TextEditingController(); 
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
    'Địa chỉ',
    'Đơn hàng',
    'Membership', 
    'Wishlist',   
  ];

  // Store the UserSession instance so we can add/remove listener
  UserSession? _userSessionInstance;


  @override
  void initState() {
    super.initState();
    // KHÔNG GỌI Provider.of<UserSession> hay _updateControllersFromUserSession() Ở ĐÂY.
    // Việc này sẽ được thực hiện trong didChangeDependencies() nơi context sẵn sàng.
  }

  // Hàm khởi tạo và cập nhật các controllers từ UserSession
  void _updateControllersFromUserSession() {
    // Đảm bảo _userSessionInstance đã được gán
    if (_userSessionInstance == null) {
      print("Lỗi: _userSessionInstance là null trong _updateControllersFromUserSession.");
      return;
    }

    // Lấy dữ liệu người dùng từ instance hiện tại của UserSession
    final User? fetchedUser = _userSessionInstance!.currentUser;

    // Chỉ cập nhật state và controllers nếu dữ liệu thực sự khác
    // để tránh rebuild không cần thiết
    if (_currentUser != fetchedUser) {
      _currentUser = fetchedUser;

      if (_currentUser != null) {
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
        if (['nam', 'nu', 'khác'].contains(genderFromUser)) {
          _genderValueForDropdown = genderFromUser;
        } else {
          _genderValueForDropdown = null; 
        }
      } else {
        // Nếu không có người dùng, xóa dữ liệu trong controllers và điều hướng
        _tenDangNhapController.clear();
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
      // Gọi setState để cập nhật UI nếu dữ liệu thay đổi
      // Đảm bảo setState được gọi chỉ khi widget còn gắn kết
      if(mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy instance của UserSession và thiết lập listener MỘT LẦN khi context sẵn sàng.
    // Provider.of(context, listen: false) an toàn ở đây.
    try {
        final newUserSessionInstance = Provider.of<UserSession>(context, listen: false);
        // Chỉ thêm listener và khởi tạo lại nếu instance thay đổi (hoặc lần đầu tiên)
        if (newUserSessionInstance != _userSessionInstance) {
          _userSessionInstance?.removeListener(_updateControllersFromUserSession); // Gỡ listener cũ nếu có
          _userSessionInstance = newUserSessionInstance; // Gán instance mới
          _userSessionInstance!.addListener(_updateControllersFromUserSession); // Thêm listener mới
          _updateControllersFromUserSession(); // Cập nhật lần đầu với dữ liệu từ Provider
        }
    } on ProviderNotFoundException catch (e) {
      print("Lỗi ProviderNotFoundException trong didChangeDependencies: $e");
      // Nếu Provider không được tìm thấy, chuyển hướng về trang đăng nhập
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
    // Gỡ lắng nghe để tránh rò rỉ bộ nhớ
    _userSessionInstance?.removeListener(_updateControllersFromUserSession);
    _tenDangNhapController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      // Sử dụng _dateOfBirth cục bộ cho initialDate. Đảm bảo nó không null.
      initialDate: _dateOfBirth ?? DateTime.now(), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    // So sánh với _dateOfBirth cục bộ
    if (picked != null && picked != _dateOfBirth) { 
      setState(() {
        _dateOfBirth = picked; // Cập nhật biến _dateOfBirth cục bộ
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(_dateOfBirth!);
        // Để lưu thay đổi này vào UserSession, bạn sẽ cần:
        // 1. Thêm một phương thức update vào lớp UserSession (ví dụ: `updateNgaySinh(DateTime? date)`)
        // 2. Gọi phương thức đó ở đây: `Provider.of<UserSession>(context, listen: false).updateNgaySinh(picked);`
      });
    }
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildPersonalInfoContent();
      case 1:
        return const AddressListScreen();
      case 2: 
        return  OrderListScreen(); 
      case 3:
        return const Center(child: Text('Nội dung Membership sẽ ở đây.'));
      case 4:
        return const Center(child: Text('Nội dung Wishlist sẽ ở đây.'));
      default:
        return const Center(child: Text('Nội dung không xác định.'));
    }
  }

  Widget _buildPersonalInfoContent() {
    return Consumer<UserSession>(
      builder: (context, userSession, child) {
        // Consumer sẽ tự động rebuild khi UserSession thông báo thay đổi
        final User? currentUser = userSession.currentUser; 

        if (currentUser == null) {
          // Lỗi này có thể xảy ra nếu UserSession.currentUser là null
          // và không có điều hướng ngay lập tức.
          // Trong trường hợp này, `_updateControllersFromUserSession` đã xử lý điều hướng.
          // Đây là một fallback an toàn.
          return const Center(child: CircularProgressIndicator()); 
        }

        // Cập nhật controllers nếu dữ liệu từ Provider đã thay đổi
        // Điều này đảm bảo rằng các controllers luôn hiển thị dữ liệu mới nhất
        // ngay cả khi _updateControllersFromUserSession() không được gọi lại ngay lập tức
        // hoặc khi có sự thay đổi từ bên ngoài (ví dụ: màn hình chỉnh sửa profile)
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
            _dateOfBirth = newDateOfBirth; // Cập nhật biến cục bộ _dateOfBirth
            _dateOfBirthController.text = _dateOfBirth != null 
                ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!) 
                : '';
        }

        final newGender = currentUser.gioiTinh?.toLowerCase();
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
              _buildTextFormField(
                label: 'Tên đăng nhập',
                controller: _tenDangNhapController,
                readOnly: true, 
              ),
              _buildTextFormField(
                label: 'Họ và tên',
                controller: _fullNameController, 
                onChanged: (value) {
                  // Bạn có thể không cần setState ở đây vì Consumer đã rebuild
                  // nếu bạn muốn lưu thay đổi ngay lập tức vào UserSession, bạn sẽ làm như sau:
                  // userSession.updateHoTen(value); (cần thêm phương thức này vào UserSession)
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
                  // Tương tự, nếu muốn lưu ngay: userSession.updateSoDienThoai(value);
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
                    items: <String>['nam', 'nu', 'khác'] 
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
                      // Tương tự, nếu muốn lưu ngay: userSession.updateGioiTinh(newValue);
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
                        userSession.clearUser(); // Gọi hàm clearUser từ instance của UserSession
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng đổi thưởng.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đổi Thưởng',
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
