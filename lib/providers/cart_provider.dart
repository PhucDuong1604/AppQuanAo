// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart'; // Đảm bảo import Product
import 'package:http/http.dart' as http; // Nếu bạn dùng http để fetch cart items
import 'dart:convert'; // Nếu bạn dùng json.decode

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false; // Thêm trạng thái tải

  List<CartItem> get items => [..._items]; // Trả về bản sao
  bool get isLoading => _isLoading;

  // Tổng số lượng sản phẩm trong giỏ hàng
  int get itemCount {
    return _items.fold(0, (total, current) => total + current.quantity);
  }

  // Tổng số tiền của các sản phẩm được chọn
  double get totalSelectedAmount {
    return _items.where((item) => item.isSelected).fold(0.0, (total, current) {
      double itemPrice = current.product.oldPrice != null && current.product.oldPrice! > 0
          ? current.product.oldPrice!
          : current.product.price;
      return total + (itemPrice * current.quantity);
    });
  }

  // Hàm để tải giỏ hàng (giả sử từ API)
  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners(); // Báo hiệu đang tải

    try {
      // Thay thế bằng URL API giỏ hàng thực tế của bạn
      final response = await http.get(Uri.parse('http://10.0.2.2/apiAppQuanAo/api/cart_items.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _items = data.map((json) => CartItem.fromJson(json)).toList();
      } else {
        // Xử lý lỗi từ server
        debugPrint('Failed to load cart items: ${response.statusCode}');
        _items = []; // Đặt trống nếu có lỗi
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      _items = []; // Đặt trống nếu có lỗi
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo hiệu đã tải xong
    }
  }

  // Thêm một CartItem mới vào giỏ hàng
  void addItem(Product product, String size, Color color, int quantity) {
    final existingItemIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingItemIndex >= 0) {
      // Cập nhật số lượng nếu sản phẩm đã tồn tại
      _items[existingItemIndex].quantity += quantity;
    } else {
      // Thêm mới nếu chưa có
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      ));
    }
    notifyListeners(); // Báo hiệu cho các listener cập nhật UI
  }

  // CẬP NHẬT: Thay đổi productId từ int sang String
  void removeItem(String productId, String selectedSize, Color selectedColor) {
    _items.removeWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );
    notifyListeners();
  }

  // CẬP NHẬT: Thay đổi productId từ int sang String
  void updateItemQuantity(String productId, String selectedSize, Color selectedColor, int newQuantity) {
    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (itemIndex >= 0) {
      if (newQuantity > 0) {
        _items[itemIndex].quantity = newQuantity;
      } else {
        // Nếu số lượng là 0, xóa sản phẩm khỏi giỏ hàng
        removeItem(productId, selectedSize, selectedColor);
      }
      notifyListeners();
    }
  }

  // CẬP NHẬT: Thay đổi productId từ int sang String
  void toggleItemSelected(String productId, String selectedSize, Color selectedColor) {
    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (itemIndex >= 0) {
      _items[itemIndex].isSelected = !_items[itemIndex].isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    notifyListeners();
  }

  // Các sản phẩm được chọn
  List<CartItem> get selectedItems {
    return _items.where((item) => item.isSelected).toList();
  }

  // Xóa tất cả các sản phẩm đã chọn
  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  // Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items = [];
    notifyListeners();
  }
}