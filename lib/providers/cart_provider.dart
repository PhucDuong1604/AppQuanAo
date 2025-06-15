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

        if (responseData.containsKey('items') && responseData['items'] is List) {
          final List<dynamic> cartData = responseData['items'];
          _items = cartData.map((json) => CartItem.fromJson(json)).toList();
        } else {
          debugPrint('API response for cart does not contain a valid "items" list, or "items" is null/not a list.');
          _items = [];
        }
      } else {
        debugPrint('Failed to load cart items: Status Code ${response.statusCode}');
        _items = [];
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phương thức addItem đã được sửa đổi để gọi API
  Future<void> addItem(Product product, String size, Color color, int quantity) async {
    // Lưu trạng thái giỏ hàng trước khi cập nhật cục bộ để có thể hoàn tác nếu API lỗi
    final List<CartItem> previousItems = List.from(_items);

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
    notifyListeners(); // Cập nhật UI ngay lập tức (optimistic update)

    // Gửi yêu cầu thêm sản phẩm lên API
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/themsanpham.php'), // THAY THẾ BẰNG ENDPOINT THÊM SẢN PHẨM VÀO GIỎ CỦA BẠN
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nguoi_dung_id': '1', // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ (ví dụ: lấy từ phiên đăng nhập)
          'san_pham_id': product.id,
          'so_luong': quantity,
          'kich_thuoc': size,
          'mau_sac': _getColorNameFromColor(color), // Chuyển đổi Color sang String cho API
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          debugPrint('Sản phẩm "${product.name}" đã được thêm vào giỏ hàng trên máy chủ thành công.');
          // Không cần làm gì thêm nếu local và server đồng bộ
        } else {
          debugPrint('Lỗi khi thêm sản phẩm vào giỏ hàng trên máy chủ: ${responseBody['message']}');
          // Hoàn tác thay đổi cục bộ nếu API báo lỗi
          _items = previousItems;
          notifyListeners();
          throw Exception('Failed to add to server cart: ${responseBody['message']}');
        }
      } else {
        debugPrint('Lỗi HTTP khi thêm sản phẩm vào giỏ hàng: Mã ${response.statusCode}');
        // Hoàn tác thay đổi cục bộ nếu có lỗi HTTP
        _items = previousItems;
        notifyListeners();
        throw Exception('Failed to add to server cart. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi thêm sản phẩm vào giỏ hàng: $e');
      // Hoàn tác thay đổi cục bộ nếu có lỗi mạng
      _items = previousItems;
      notifyListeners();
      throw Exception('Network error or other issue: $e');
    }
  }

  void removeItem(String productId, String selectedSize, Color selectedColor) {
    _items.removeWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );
    notifyListeners();
    // TODO: Thêm logic gọi API để xóa sản phẩm khỏi giỏ hàng trên máy chủ tại đây
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
      // TODO: Thêm logic gọi API để cập nhật số lượng sản phẩm trên máy chủ tại đây
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
    // TODO: Thêm logic gọi API để xóa các sản phẩm đã chọn khỏi giỏ hàng trên máy chủ tại đây
  }

  void clearCart() {
    _items = [];
    notifyListeners();
    // TODO: Thêm logic gọi API để xóa toàn bộ giỏ hàng trên máy chủ tại đây
  }
}

// Hàm helper để chuyển đổi đối tượng Color thành tên màu (String)
// Đặt hàm này ở ngoài class để có thể tái sử dụng hoặc truy cập dễ dàng.
// Có thể cân nhắc đặt hàm này ở một file tiện ích (utils) riêng biệt nếu bạn dùng nó nhiều nơi
String _getColorNameFromColor(Color color) {
  if (color == Colors.red) return 'Đỏ';
  if (color == Colors.blue) return 'Xanh';
  if (color == Colors.black) return 'Đen';
  if (color == Colors.white) return 'Trắng';
  if (color == Colors.yellow) return 'Vàng';
  if (color == Colors.grey) return 'Xám';
  if (color == Colors.orange) return 'Cam';
  if (color == Colors.purple) return 'Tím';
  if (color == Colors.brown) return 'Nâu';
  if (color == Colors.pink) return 'Hồng';
  if (color == Colors.green) return 'Xanh lá';
  // Thêm các màu khác nếu cần
  return 'Không xác định'; // Mặc định cho Colors.transparent hoặc các màu không xác định
}