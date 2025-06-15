import 'package:flutter/material.dart';
import 'package:appquanao/models/product.dart'; // Đảm bảo import Product model của bạn

class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;
  final Color selectedColor;
  bool isSelected;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.isSelected = true, // Mặc định là true khi thêm vào giỏ hàng
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // === SỬA ĐỔI QUAN TRỌNG NHẤT Ở ĐÂY ===
    // Truyền toàn bộ đối tượng JSON của cart item vào Product.fromJson
    // vì thông tin sản phẩm nằm trực tiếp trong đó.
    final Product parsedProduct = Product.fromJson(json);

    return CartItem(
      product: parsedProduct,
      quantity: (json['so_luong'] as int?) ?? 1,
      // Sửa từ 'kich_thuoc' thành 'kich_co' để khớp với JSON API
      selectedSize: (json['kich_co'] as String?) ?? 'N/A',
      selectedColor: _getColorFromString((json['mau_sac'] as String?) ?? 'Transparent'),
      // isSelected không có trong JSON, giữ mặc định hoặc quản lý client-side
      isSelected: true, // Mặc định là true khi được tải (hoặc true nếu bạn muốn bắt đầu từ đó)
                        // Nếu API có trường is_selected và bạn muốn dùng nó, bạn sẽ thêm logic ở đây
    );
  }

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
      default: return Colors.transparent;
    }
  }

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