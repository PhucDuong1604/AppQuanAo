// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => [..._items];
  bool get isLoading => _isLoading;

  int get itemCount {
    return _items.fold(0, (total, current) => total + current.quantity);
  }

  double get totalSelectedAmount {
    return _items.where((item) => item.isSelected).fold(0.0, (total, current) {
      double itemPrice = current.product.price;
      return total + (itemPrice * current.quantity);
    });
  }

  Future<void> fetchCartItems(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/giohang.php?nguoi_dung_id=$userId'));

      if (response.statusCode == 200) {
        debugPrint('FULL API Response Body for Cart: ${response.body}');

        final Map<String, dynamic> responseData = json.decode(response.body);

        // --- ĐÂY LÀ PHẦN THAY ĐỔI QUAN TRỌNG NHẤT ---
        // Kiểm tra xem 'items' có tồn tại và có phải là một List không
        if (responseData.containsKey('items') && responseData['items'] is List) {
          final List<dynamic> cartData = responseData['items']; // Lấy danh sách từ khóa 'items'
          _items = cartData.map((json) => CartItem.fromJson(json)).toList();
        } else {
          // Xử lý trường hợp 'items' không tồn tại hoặc không phải là List
          // Đây sẽ là log nếu giỏ hàng trống hoặc có cấu trúc không mong đợi
          debugPrint('API response for cart does not contain a valid "items" list, or "items" is null/not a list.');
          _items = []; // Đặt trống giỏ hàng nếu dữ liệu không hợp lệ
        }
      } else {
        // Xử lý lỗi từ server (ví dụ: status 404, 500)
        debugPrint('Failed to load cart items: Status Code ${response.statusCode}');
        _items = []; // Đặt trống nếu có lỗi HTTP
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      _items = []; // Đặt trống nếu có lỗi ngoại lệ
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Các hàm còn lại giữ nguyên
  // ... (addItem, removeItem, updateItemQuantity, toggleItemSelected, toggleSelectAll, selectedItems, removeSelectedItems, clearCart) ...

  void addItem(Product product, String size, Color color, int quantity) {
    final existingItemIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId, String selectedSize, Color selectedColor) {
    _items.removeWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );
    notifyListeners();
  }

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
        removeItem(productId, selectedSize, selectedColor);
      }
      notifyListeners();
    }
  }

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

  List<CartItem> get selectedItems {
    return _items.where((item) => item.isSelected).toList();
  }

  void removeSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}