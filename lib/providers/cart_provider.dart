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

  Future<void> addItem(Product product, String size, Color color, int quantity) async {
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
    notifyListeners(); // Optimistic update

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/themsanpham.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nguoi_dung_id': '1', // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ
          'san_pham_id': product.id,
          'so_luong': quantity,
          'kich_thuoc': size,
          'mau_sac': _getColorNameFromColor(color),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          debugPrint('Sản phẩm "${product.name}" đã được thêm vào giỏ hàng trên máy chủ thành công.');
        } else {
          debugPrint('Lỗi khi thêm sản phẩm vào giỏ hàng trên máy chủ: ${responseBody['message']}');
          _items = previousItems;
          notifyListeners();
          throw Exception('Failed to add to server cart: ${responseBody['message']}');
        }
      } else {
        debugPrint('Lỗi HTTP khi thêm sản phẩm vào giỏ hàng: Mã ${response.statusCode}');
        _items = previousItems;
        notifyListeners();
        throw Exception('Failed to add to server cart. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi thêm sản phẩm vào giỏ hàng: $e');
      _items = previousItems;
      notifyListeners();
      throw Exception('Network error or other issue: $e');
    }
  }

  // Phương thức xóa sản phẩm khỏi giỏ hàng (bao gồm API call)
  Future<void> removeItem(String productId, String selectedSize, Color selectedColor) async {
    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (itemIndex < 0) return; // Item not found

    final CartItem itemToRemove = _items[itemIndex];
    final List<CartItem> previousItems = List.from(_items); // Lưu trạng thái trước

    // Optimistic update: xóa ngay lập tức trên UI
    _items.removeAt(itemIndex);
    notifyListeners();

    try {
      // Giả sử bạn có thể lấy gio_hang_id và thuoc_tinh_id từ itemToRemove
      // Điều này có thể yêu cầu bạn phải fetch cart items từ API trước đó
      // hoặc lưu trữ gio_hang_id và thuoc_tinh_id trong CartItem model khi fetch
      // For now, let's assume we fetch cart_items again to get gio_hang_id and thuoc_tinh_id if needed.
      // Or, the CartItem model should contain these IDs if fetched from DB.
      // Dành cho ví dụ này, chúng ta sẽ cần 'gio_hang_id' và 'thuoc_tinh_id' từ database.
      // Nếu CartItem của bạn có đủ thông tin này sau khi fetchCartItems, bạn có thể truyền trực tiếp.
      // Nếu không, bạn cần một cách để lấy chúng.
      // Tạm thời, tôi sẽ giả định itemToRemove.gioHangId và itemToRemove.thuocTinhId đã có.
      // Nếu không, bạn sẽ cần fetch lại cart hoặc truyền các ID này vào CartItem model.

      // Để đơn giản, tôi sẽ giả định lại fetch gio_hang_id và thuoc_tinh_id ở đây.
      // Thực tế, bạn nên sửa model CartItem để bao gồm các ID này sau khi fetch từ DB.
      // Ví dụ: cart_item.dart:
      // class CartItem {
      //   final String id; // ID của chi_tiet_gio_hang
      //   final String gioHangId;
      //   final String thuocTinhId;
      //   ...
      // }

      // Vì lý do ví dụ và đơn giản, chúng ta cần một cách để lấy thuoc_tinh_id.
      // Nếu API fetchCartItems của bạn trả về đủ thông tin, CartItem có thể chứa ID đó.
      // Hiện tại, chúng ta sẽ truyền san_pham_id, kich_thuoc, mau_sac để PHP tự tìm.
      // Cần có nguoi_dung_id để tìm gio_hang_id trên server.
      final String currentUserId = '1'; // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ

      final response = await http.post(
        Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/capnhatsoluong.php'), // Sử dụng API cập nhật số lượng (để xóa = 0)
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nguoi_dung_id': currentUserId, // Cần gửi user ID để PHP tìm gio_hang_id
          'san_pham_id': itemToRemove.product.id,
          'kich_thuoc': itemToRemove.selectedSize,
          'mau_sac': _getColorNameFromColor(itemToRemove.selectedColor),
          'new_so_luong': 0, // Gửi 0 để báo xóa
          // Note: Thực tế lý tưởng nhất là gửi gio_hang_id và thuoc_tinh_id đã biết
          // từ client nếu bạn đã fetch chúng trước đó.
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          debugPrint('Sản phẩm đã được xóa khỏi giỏ hàng trên máy chủ thành công.');
        } else {
          debugPrint('Lỗi khi xóa sản phẩm khỏi giỏ hàng trên máy chủ: ${responseBody['message']}');
          _items = previousItems; // Hoàn tác
          notifyListeners();
          throw Exception('Failed to remove from server cart: ${responseBody['message']}');
        }
      } else {
        debugPrint('Lỗi HTTP khi xóa sản phẩm khỏi giỏ hàng: Mã ${response.statusCode}');
        _items = previousItems; // Hoàn tác
        notifyListeners();
        throw Exception('Failed to remove from server cart. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi xóa sản phẩm khỏi giỏ hàng: $e');
      _items = previousItems; // Hoàn tác
      notifyListeners();
      throw Exception('Network error or other issue: $e');
    }
  }

  // Phương thức updateItemQuantity đã sửa đổi để gọi API
  Future<void> updateItemQuantity(String productId, String selectedSize, Color selectedColor, int newQuantity) async {
    final itemIndex = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          item.selectedSize == selectedSize &&
          item.selectedColor == selectedColor,
    );

    if (itemIndex < 0) return; // Không tìm thấy sản phẩm

    final CartItem itemToUpdate = _items[itemIndex];
    final int oldQuantity = itemToUpdate.quantity;
    final List<CartItem> previousItems = List.from(_items); // Lưu trạng thái trước

    if (newQuantity <= 0) {
      // Nếu số lượng mới là 0 hoặc âm, coi như xóa sản phẩm
      return removeItem(productId, selectedSize, selectedColor);
    }

    // Optimistic update: cập nhật ngay lập tức trên UI
    _items[itemIndex].quantity = newQuantity;
    notifyListeners();

    try {
      // Giả định bạn có thể lấy gio_hang_id và thuoc_tinh_id từ itemToUpdate
      // Bạn cần đảm bảo CartItem model của bạn có các trường này sau khi fetch từ DB.
      // Nếu không có, bạn cần logic để lấy chúng (ví dụ: tìm lại trên server).
      // Tạm thời, tôi sẽ giả định itemToUpdate.gioHangId và itemToUpdate.thuocTinhId đã có.
      // Nếu không, bạn cần một cách để lấy chúng.
      final String currentUserId = '1'; // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ

      final response = await http.post(
        Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/capnhatsoluong.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nguoi_dung_id': currentUserId, // Cần gửi user ID để PHP tìm gio_hang_id
          'san_pham_id': itemToUpdate.product.id,
          'kich_thuoc': itemToUpdate.selectedSize,
          'mau_sac': _getColorNameFromColor(itemToUpdate.selectedColor),
          'new_so_luong': newQuantity,
          // Note: Thực tế lý tưởng nhất là gửi gio_hang_id và thuoc_tinh_id đã biết
          // từ client nếu bạn đã fetch chúng trước đó.
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          debugPrint('Số lượng sản phẩm đã được cập nhật trên máy chủ thành công.');
        } else {
          debugPrint('Lỗi khi cập nhật số lượng sản phẩm trên máy chủ: ${responseBody['message']}');
          _items = previousItems; // Hoàn tác
          notifyListeners();
          throw Exception('Failed to update server cart quantity: ${responseBody['message']}');
        }
      } else {
        debugPrint('Lỗi HTTP khi cập nhật số lượng sản phẩm: Mã ${response.statusCode}');
        _items = previousItems; // Hoàn tác
        notifyListeners();
        throw Exception('Failed to update server cart quantity. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi cập nhật số lượng sản phẩm: $e');
      _items = previousItems; // Hoàn tác
      notifyListeners();
      throw Exception('Network error or other issue: $e');
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

  Future<void> removeSelectedItems() async {
    final List<CartItem> itemsToRemove = _items.where((item) => item.isSelected).toList();
    if (itemsToRemove.isEmpty) return;

    final List<CartItem> previousItems = List.from(_items); // Lưu trạng thái trước

    _items.removeWhere((item) => item.isSelected); // Optimistic update
    notifyListeners();

    try {
      // Thực hiện xóa từng mục trên server hoặc gửi một request xóa hàng loạt
      // Để đơn giản, ta sẽ gửi từng request xóa (new_so_luong = 0)
      final String currentUserId = '1'; // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ

      for (var item in itemsToRemove) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/capnhatsoluong.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nguoi_dung_id': currentUserId,
            'san_pham_id': item.product.id,
            'kich_thuoc': item.selectedSize,
            'mau_sac': _getColorNameFromColor(item.selectedColor),
            'new_so_luong': 0, // Xóa
          }),
        );

        if (response.statusCode != 200) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          debugPrint('Lỗi khi xóa sản phẩm đã chọn khỏi máy chủ: ${item.product.name} - ${responseBody['message']}');
          // Có thể chọn hoàn tác toàn bộ hoặc chỉ các mục lỗi
          // Để đơn giản, ném lỗi để hoàn tác toàn bộ trong catch block
          throw Exception('Failed to remove some selected items from server cart.');
        }
      }
      debugPrint('Đã xóa các sản phẩm đã chọn khỏi giỏ hàng trên máy chủ thành công.');
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi xóa các sản phẩm đã chọn: $e');
      _items = previousItems; // Hoàn tác nếu có lỗi
      notifyListeners();
      throw Exception('Network error or other issue when removing selected items: $e');
    }
  }

  Future<void> clearCart() async {
    final List<CartItem> previousItems = List.from(_items); // Lưu trạng thái trước
    _items = []; // Optimistic update
    notifyListeners();

    try {
      final String currentUserId = '1'; // THAY THẾ BẰNG ID NGƯỜI DÙNG THỰC TẾ

      // Giả định bạn có một API endpoint để xóa toàn bộ giỏ hàng của người dùng
      final response = await http.post(
        Uri.parse('http://10.0.2.2/apiAppQuanAo/api/giohang/xoatoanbogiỏhang.php'), // Cần tạo API này
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nguoi_dung_id': currentUserId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['success'] == true) {
          debugPrint('Đã xóa toàn bộ giỏ hàng trên máy chủ thành công.');
        } else {
          debugPrint('Lỗi khi xóa toàn bộ giỏ hàng trên máy chủ: ${responseBody['message']}');
          _items = previousItems; // Hoàn tác
          notifyListeners();
          throw Exception('Failed to clear server cart: ${responseBody['message']}');
        }
      } else {
        debugPrint('Lỗi HTTP khi xóa toàn bộ giỏ hàng: Mã ${response.statusCode}');
        _items = previousItems; // Hoàn tác
        notifyListeners();
        throw Exception('Failed to clear server cart. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi mạng hoặc lỗi khác khi xóa toàn bộ giỏ hàng: $e');
      _items = previousItems; // Hoàn tác
      notifyListeners();
      throw Exception('Network error or other issue when clearing cart: $e');
    }
  }
}

// Hàm helper để chuyển đổi đối tượng Color thành tên màu (String)
// Đặt hàm này ở ngoài class để có thể tái sử dụng hoặc truy cập dễ dàng.
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
  return 'Không xác định';
}