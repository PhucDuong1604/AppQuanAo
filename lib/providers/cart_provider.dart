import 'package:appquanao/Models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:appquanao/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  UserSession? _userSession;

  List<CartItem> get items => _items;

  double get totalSelectedAmount {
    return _items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  List<CartItem> get selectedItems {
    return _items.where((item) => item.isSelected).toList();
  }

  void updateUserInfo(UserSession userSession) {
    _userSession = userSession;
    if (_userSession?.currentUser?.id != null && _items.isEmpty) {
      fetchCartItems();
    }
  }

  Future<void> fetchCartItems() async {
    // ... (Giữ nguyên logic fetchCartItems đã có)
    final userId = _userSession?.currentUser?.id;
    if (userId == null) {
      print('CartProvider: Không có User ID để tải giỏ hàng.');
      _items = [];
      notifyListeners();
      return;
    }

    final Uri uri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/giohang.php?nguoi_dung_id=$userId');
    print('CartProvider: Đang tải giỏ hàng từ: $uri');

    try {
      final response = await http.get(uri);
      print('CartProvider: Status Code: ${response.statusCode}');
      print('CartProvider: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is List) {
          // Lưu ý: nếu API không trả về is_selected, mặc định isSelected là true trong CartItem.fromJson
          _items = responseData.map((json) => CartItem.fromJson(json)).toList();
          print('CartProvider: Đã tải thành công ${_items.length} mặt hàng.');
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          _items = [];
          print('CartProvider: API trả về thông báo: ${responseData['message']}');
        } else {
          _items = [];
          print('CartProvider: Dữ liệu giỏ hàng không hợp lệ: ${response.body}');
        }
      } else {
        _items = [];
        print('CartProvider: Lỗi API khi tải giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      _items = [];
      print('CartProvider: Lỗi kết nối khi tải giỏ hàng: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> addItem(Product product, String size, String color, int quantity) async {
    final userId = _userSession?.currentUser?.id;
    if (userId == null) {
      print('Không thể thêm vào giỏ hàng: Người dùng chưa đăng nhập.');
      return;
    }

    final existingItemIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      ));
    }

    await _syncCartToServer(userId, product.id, quantity, size, color, existingItemIndex != -1 ? 'update' : 'add');
    notifyListeners();
  }

  Future<void> removeItem(int productId, String size, String color) async {
    final userId = _userSession?.currentUser?.id;
    if (userId == null) return;

    _items.removeWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    await _syncCartToServer(userId, productId, 0, size, color, 'remove');
    notifyListeners();
  }

  Future<void> updateItemQuantity(int productId, String size, String color, int newQuantity) async {
    final userId = _userSession?.currentUser?.id;
    if (userId == null) return;

    if (newQuantity <= 0) {
      removeItem(productId, size, color);
      return;
    }

    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (itemIndex != -1) {
      _items[itemIndex].quantity = newQuantity;
      await _syncCartToServer(userId, productId, newQuantity, size, color, 'update');
    }
    notifyListeners();
  }

  void toggleItemSelected(int productId, String size, String color) {
    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );
    if (itemIndex != -1) {
      _items[itemIndex].isSelected = !_items[itemIndex].isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool select) {
    for (var item in _items) {
      item.isSelected = select;
    }
    notifyListeners();
  }

  // >>> THÊM PHƯƠNG THỨC NÀY <<<
  // Xóa các sản phẩm đã được chọn khỏi giỏ hàng (cả trên client và server)
  Future<void> removeSelectedItems() async {
    final userId = _userSession?.currentUser?.id;
    if (userId == null) return;

    final itemsToRemove = _items.where((item) => item.isSelected).toList();
    if (itemsToRemove.isEmpty) return;

    // Xóa trên server từng item một
    for (var item in itemsToRemove) {
      await _syncCartToServer(
          userId, item.product.id, 0, item.selectedSize, item.selectedColor, 'remove');
    }

    // Sau khi xóa trên server, cập nhật lại danh sách trên client
    // Cách an toàn nhất là fetch lại toàn bộ giỏ hàng từ server
    // Hoặc lọc ra những item không được chọn
    _items.removeWhere((item) => item.isSelected); // Xóa trên client
    notifyListeners(); // Thông báo cho UI cập nhật
    print('Đã xóa ${itemsToRemove.length} sản phẩm đã chọn khỏi giỏ hàng.');

    // Hoặc bạn có thể gọi fetchCartItems() để đảm bảo đồng bộ hoàn toàn
    // await fetchCartItems();
  }

  // Xóa toàn bộ giỏ hàng (nếu bạn muốn có chức năng này)
  Future<void> clearCart() async {
    final userId = _userSession?.currentUser?.id;
    if (userId == null) return;

    _items = []; // Xóa trên client
    // TODO: Gửi yêu cầu API để xóa toàn bộ giỏ hàng trên server (cần API riêng)
    // Ví dụ: await _syncCartToServer(userId, 0, 0, '', '', 'clear_all');
    // Hoặc tạo một API riêng chỉ để clear giỏ hàng:
    final Uri clearUri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/sgiohang.php?nguoi_dung_id=$userId');
     try {
      final response = await http.post(
        clearUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'action': 'clear_all'}),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print('Xóa toàn bộ giỏ hàng trên server thành công.');
        } else {
          print('Xóa toàn bộ giỏ hàng trên server thất bại: ${responseData['message']}');
        }
      } else {
        print('Lỗi server khi xóa toàn bộ giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối khi xóa toàn bộ giỏ hàng: $e');
    }
    notifyListeners();
  }


  Future<void> _syncCartToServer(int userId, int productId, int quantity, String size, String color, String action) async {
    final Uri uri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/giohang.php?nguoi_dung_id=$userId');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity,
          'size': size,
          'color': color,
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print('Đồng bộ giỏ hàng thành công: ${responseData['message']}');
        } else {
          print('Đồng bộ giỏ hàng thất bại: ${responseData['message']}');
        }
      } else {
        print('Lỗi server khi đồng bộ giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối khi đồng bộ giỏ hàng: $e');
    }
  }
}