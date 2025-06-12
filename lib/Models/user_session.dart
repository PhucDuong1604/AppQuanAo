import 'package:flutter/foundation.dart'; // Cần cho ChangeNotifier
import 'package:intl/intl.dart'; 

class User {
  final int id;
  final String email;
  final String? hoTen; 
  final String? soDienThoai; 
  final String? diaChi;
  final DateTime? ngaySinh; 
  final String? gioiTinh; 
  final bool trangThai;

  User({
    required this.id,
    required this.email,
    this.hoTen,
    this.soDienThoai,
    this.diaChi,
    this.ngaySinh,
    this.gioiTinh, 
    required this.trangThai,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parsedNgaySinh;
    if (json['ngay_sinh'] != null && (json['ngay_sinh'] as String).isNotEmpty) {
      try {
        parsedNgaySinh = DateFormat('yyyy-MM-dd').parse(json['ngay_sinh'] as String);
      } catch (e) {
        print("Lỗi khi parse ngay_sinh từ JSON: $e");
        parsedNgaySinh = null;
      }
    }

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      hoTen: json['ho_ten'] as String?, 
      soDienThoai: json['so_dien_thoai'] as String?, 
      diaChi: json['dia_chi'] as String?,
      ngaySinh: parsedNgaySinh, 
      gioiTinh: json['gioi_tinh'] as String?, 
      trangThai: json['trang_thai'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'ho_ten': hoTen, 
      'so_dien_thoai': soDienThoai,
      'dia_chi': diaChi,
      'ngay_sinh': ngaySinh?.toIso8601String().split('T')[0], 
      'gioi_tinh': gioiTinh,
      'trang_thai': trangThai,
    };
  }
}

// ĐẢM BẢO LỚP NÀY KẾ THỪA ChangeNotifier
class UserSession extends ChangeNotifier { 
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  User? _currentUser; 

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners(); // THÔNG BÁO KHI DỮ LIỆU THAY ĐỔI
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners(); // THÔNG BÁO KHI DỮ LIỆU THAY ĐỔI
  }
}
