// appquanao/models/cart_item.dart

import 'package:flutter/material.dart'; // Chỉ để dùng Color nếu cần, không bắt buộc

// Model cơ bản cho một sản phẩm (để nhúng vào CartItem)
// Bạn có thể đã có model Product riêng nếu quản lý sản phẩm
class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  // Thêm các thuộc tính khác của sản phẩm nếu cần (ví dụ: description, category)

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['ten_san_pham'] as String,
      imageUrl: json['hinh_anh'] as String? ?? 'https://placehold.co/100x100/A0A0A0/FFFFFF?text=No+Image', // URL hình ảnh, cung cấp fallback
      price: (json['gia'] as num).toDouble(),
    );
  }
}

// Model cho một mặt hàng trong giỏ hàng
class CartItem {
  final Product product; // Thông tin sản phẩm
  int quantity; // Số lượng sản phẩm này trong giỏ hàng
  final String selectedSize; // Kích thước được chọn
  final String selectedColor; // Màu sắc được chọn
  bool isSelected; // Trạng thái được chọn để thanh toán

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.isSelected = true, // Mặc định là được chọn
  });

  // Constructor factory để tạo CartItem từ JSON response của API
  // API sẽ trả về dữ liệu JOIN từ gio_hang và san_pham
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      // Tạo đối tượng Product từ các trường liên quan đến sản phẩm
      product: Product(
        id: json['san_pham_id'] as int,
        name: json['ten_san_pham'] as String,
        imageUrl: json['hinh_anh'] as String? ?? 'https://placehold.co/100x100/A0A0A0/FFFFFF?text=No+Image',
        price: (json['gia'] as num).toDouble(),
      ),
      quantity: json['so_luong'] as int,
      selectedSize: json['kich_co'] as String, // Giả định kich_co là NOT NULL từ DB
      selectedColor: json['mau_sac'] as String, // Giả định mau_sac là NOT NULL từ DB
      isSelected: (json['is_selected'] as int? ?? 1) == 1, // Mặc định là 1 (true) nếu không có
    );
  }

  // Phương thức để cập nhật trạng thái isSelected
  CartItem copyWith({
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}