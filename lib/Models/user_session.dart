import 'package:flutter/material.dart';
class User {
  final int id; // Đã thêm 'id' và để kiểu 'int'
  final String email;
  final String? hoTen;
  final String? soDienThoai;
  final DateTime? ngaySinh; // Đã thêm 'ngaySinh'
  final String? gioiTinh;
  final bool? trangThai; // Giả sử API có trả về trạng thái tài khoản

  User({
    required this.id, // Yêu cầu 'id' khi tạo User
    required this.email,
    this.hoTen,
    this.soDienThoai,
    this.ngaySinh,
    this.gioiTinh,
    this.trangThai,
  });

  // Constructor copy để tạo một đối tượng User mới với các trường được thay đổi.
  // Điều này là cần thiết vì User là immutable (final fields).
  User copyWith({
    int? id, // Cập nhật kiểu dữ liệu của id thành int?
    String? email,
    String? hoTen,
    String? soDienThoai,
    DateTime? ngaySinh,
    String? gioiTinh,
    String? tenDangNhap,
    bool? trangThai,
  }) {
    return User(
      id: id ?? this.id, // Đảm bảo gán đúng 'id' hoặc giữ 'this.id'
      email: email ?? this.email, // Đảm bảo gán đúng 'email' hoặc giữ 'this.email'
      hoTen: hoTen ?? this.hoTen,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      trangThai: trangThai ?? this.trangThai,
    );
  }
}

class UserSession with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User? user) {
    _currentUser = user;
    print('UserSession: setUser called. currentUser is now: ${_currentUser?.hoTen ?? "null"}');
    notifyListeners(); // Thông báo cho các listeners rằng dữ liệu đã thay đổi
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners(); // Thông báo khi người dùng đăng xuất
  }

  // --- CÁC PHƯƠNG THỨC UPDATE MỚI CẦN THÊM VÀO ---

  void updateHoTen(String? newHoTen) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(hoTen: newHoTen);
      notifyListeners();
    }
  }

  void updateSoDienThoai(String? newSoDienThoai) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(soDienThoai: newSoDienThoai);
      notifyListeners();
    }
  }

  void updateNgaySinh(DateTime? newNgaySinh) {
    // Đã thêm phương thức update cho ngaySinh
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(ngaySinh: newNgaySinh);
      notifyListeners();
    }
  }

  void updateGioiTinh(String? newGioiTinh) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(gioiTinh: newGioiTinh);
      notifyListeners();
    }
  }

  // Bạn có thể thêm các phương thức update khác nếu cần
  void updateEmail(String? newEmail) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(email: newEmail);
      notifyListeners();
    }
  }

  void updateTenDangNhap(String? newTenDangNhap) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(tenDangNhap: newTenDangNhap);
      notifyListeners();
    }
  }

  void updateTrangThai(bool? newTrangThai) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(trangThai: newTrangThai);
      notifyListeners();
    }
  }
}