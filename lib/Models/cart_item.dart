// lib/models/cart_item.dart
import 'package:flutter/material.dart';
import 'package:appquanao/models/product.dart'; // Đảm bảo import Product model của bạn

class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;
  final Color selectedColor; // Đã thay đổi thành kiểu Color
  bool isSelected;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.isSelected = true, // Mặc định là true khi thêm vào giỏ hàng
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Để ý cách chúng ta chuyển 'mau_sac' từ String sang Color
    // Đảm bảo json['product_info'] tồn tại và là một Map
    // Nếu không, tạo một Product rỗng hoặc ném lỗi có ý nghĩa
    Product parsedProduct;
    if (json.containsKey('product_info') && json['product_info'] is Map<String, dynamic>) {
      parsedProduct = Product.fromJson(json['product_info'] as Map<String, dynamic>);
    } else {
      // Xử lý trường hợp không có product_info hoặc sai định dạng
      // Bạn có thể log lỗi ở đây hoặc tạo một Product mặc định/rỗng
      // Ví dụ: log lỗi và dùng một Product mặc định
      debugPrint('Warning: product_info not found or invalid in CartItem JSON: $json');
      parsedProduct = Product(
        id: 'error_id',
        name: 'Sản phẩm không có sẵn',
        imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Lỗi', // Ảnh báo lỗi
        price: 0.0,
        description: 'Thông tin sản phẩm không thể tải.',
        category: 'Lỗi',
        sizes: [],
        colors: [],
        rating: 0.0,
        reviewCount: 0,
      );
    }

    return CartItem(
      product: parsedProduct,
      quantity: (json['so_luong'] as int?) ?? 1, // Dùng ?? 1 để tránh null nếu so_luong không có
      selectedSize: (json['kich_thuoc'] as String?) ?? 'N/A',
      selectedColor: _getColorFromString((json['mau_sac'] as String?) ?? 'Transparent'), // Fallback màu
      isSelected: (json['is_selected'] as int?) == 1, // Dùng ?? 1 để mặc định là true nếu không có
    );
  }

  // Hàm trợ giúp để chuyển đổi String tên màu thành đối tượng Color
  static Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'đỏ': return Colors.red;
      case 'xanh': return Colors.blue;
      case 'đen': return Colors.black;
      case 'trắng': return Colors.white;
      case 'vàng': return Colors.yellow;
      case 'xám': return Colors.grey;
      case 'cam': return Colors.orange;
      case 'tím': return Colors.purple;
      case 'nâu': return Colors.brown;
      case 'hồng': return Colors.pink;
      case 'xanh lá': return Colors.green;
      default: return Colors.transparent; // Màu mặc định nếu không tìm thấy
    }
  }

  // Bạn có thể thêm phương thức copyWith nếu cần để tạo bản sao của CartItem
  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
    Color? selectedColor,
    bool? isSelected,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}