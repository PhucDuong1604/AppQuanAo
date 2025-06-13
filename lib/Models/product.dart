// lib/models/product.dart
import 'package:flutter/material.dart';

class Product {
  final String id; // id_sanpham
  final String name; // ten_sanpham
  final String imageUrl; // hinh_anh
  final double price; // gia
  final double? oldPrice; // gia_cu (có thể null)
  final String description; // mo_ta
  final String category; // category (sẽ thêm vào PHP)
  final List<String> sizes; // kich_thuoc (chuỗi 'S,M,L' chuyển thành List)
  final List<String> colors; // mau_sac (chuỗi 'đỏ,xanh' chuyển thành List)
  final double rating; // danh_gia
  final int reviewCount; // so_luong_danh_gia

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    required this.description,
    required this.category,
    required this.sizes,
    required this.colors,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi chuỗi 'kich_thuoc' thành List<String>
    final List<String> parsedSizes = (json['kich_thuoc'] as String?)
            ?.split(',') // Tách chuỗi theo dấu phẩy
            .map((e) => e.trim()) // Loại bỏ khoảng trắng thừa
            .where((e) => e.isNotEmpty) // Lọc bỏ các chuỗi rỗng
            .toList() ??
        []; // Nếu null, trả về danh sách rỗng

    // Chuyển đổi chuỗi 'mau_sac' thành List<String>
    final List<String> parsedColors = (json['mau_sac'] as String?)
            ?.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    return Product(
      id: json['id_sanpham'].toString(), // Đảm bảo ID là String, vì trong Flutter dùng String cho ID
      name: json['ten_sanpham'] as String,
      imageUrl: json['hinh_anh'] as String,
      price: (json['gia'] as num).toDouble(), // num để xử lý cả int và double từ JSON
      oldPrice: (json['gia_cu'] as num?)?.toDouble(), // Có thể null
      description: json['mo_ta'] as String,
      category: json['category'] as String? ?? 'Chưa phân loại', // Xử lý nếu category không có trong JSON
      sizes: parsedSizes,
      colors: parsedColors,
      rating: (json['danh_gia'] as num).toDouble(),
      reviewCount: (json['so_luong_danh_gia'] as int),
    );
  }
}