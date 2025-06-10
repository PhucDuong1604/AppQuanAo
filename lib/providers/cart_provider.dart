import 'package:flutter/material.dart';
import 'package:appquanao/models/cart_item.dart';
import 'package:appquanao/models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Tổng tiền của CÁC SẢN PHẨM ĐƯỢC CHỌN
  double get totalSelectedAmount { // Đổi tên getter để tránh nhầm lẫn
    double total = 0.0;
    for (var item in _items) {
      if (item.isSelected) { // Chỉ tính tổng nếu sản phẩm được chọn
        total += item.totalPrice;
      }
    }
    return total;
  }

  // Phương thức để bật/tắt chọn một sản phẩm
  void toggleItemSelected(String productId, String selectedSize, Color selectedColor) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );
    if (index != -1) {
      _items[index].isSelected = !_items[index].isSelected; // Đảo ngược trạng thái chọn
      notifyListeners();
    }
  }

  // Phương thức để chọn/bỏ chọn TẤT CẢ sản phẩm
  void toggleSelectAll(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    notifyListeners();
  }

  // Phương thức để lấy danh sách các sản phẩm ĐƯỢC CHỌN
  List<CartItem> get selectedItems {
    return _items.where((item) => item.isSelected).toList();
  }

  // Phương thức để XÓA các sản phẩm đã thanh toán
  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  // Các phương thức khác giữ nguyên
  void addItem(Product product, String selectedSize, Color selectedColor) {
    int existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
          isSelected: true, // Mặc định được chọn khi thêm vào giỏ hàng
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId, String selectedSize, Color selectedColor) {
    _items.removeWhere((item) =>
        item.product.id == productId &&
        item.selectedSize == selectedSize &&
        item.selectedColor == selectedColor);
    notifyListeners();
  }

  void updateItemQuantity(String productId, String selectedSize, Color selectedColor, int newQuantity) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );
    if (index != -1) {
      if (newQuantity <= 0) {
        removeItem(productId, selectedSize, selectedColor);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}