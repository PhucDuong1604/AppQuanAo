import 'package:flutter/material.dart';



class Product {

 final String id;
 final String name; 
 final String imageUrl;
 final double price; 
 final double? oldPrice;
 final String description;
 final String category; 
 final List<String> sizes;
 final List<String> colors;
 final double rating; 
 final int reviewCount; 

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

// Xử lý an toàn cho kich_thuoc và mau_sac, đảm bảo không null và là List<String>
final List<String> parsedSizes = (json['kich_thuoc'] as String?)
?.split(',') // Tách chuỗi theo dấu phẩy
.map((e) => e.trim()) // Loại bỏ khoảng trắng thừa
.where((e) => e.isNotEmpty) // Lọc bỏ các chuỗi rỗng
.toList() ??
[]; // Nếu null, trả về danh sách rỗng
final List<String> parsedColors = (json['mau_sac'] as String?)
?.split(',')
.map((e) => e.trim())
.where((e) => e.isNotEmpty)
.toList() ??
[];
return Product(

// id_sanpham: Luôn ép về String và không bao giờ null
id: json['id_sanpham'].toString(),

// ten_sanpham: Có thể là String hoặc null từ JSON, cung cấp giá trị mặc định
name: json['ten_sanpham'] as String? ?? 'Tên sản phẩm không xác định',
// hinh_anh: Có thể là String hoặc null, cung cấp giá trị mặc định
imageUrl: json['hinh_anh'] as String? ?? 'https://via.placeholder.com/150',
// gia: Có thể là num hoặc null, cung cấp giá trị mặc định
price: (json['gia'] as num?)?.toDouble() ?? 0.0,
// gia_cu: Có thể là num hoặc null, không cung cấp giá trị mặc định vì đã là nullable trong model
oldPrice: (json['gia_cu'] as num?)?.toDouble(),
// mo_ta: Có thể là String hoặc null, cung cấp giá trị mặc định
description: json['mo_ta'] as String? ?? 'Không có mô tả cho sản phẩm này.',
// category: Có thể là String hoặc null, cung cấp giá trị mặc định
category: json['category'] as String? ?? 'Chưa phân loại',
sizes: parsedSizes,
colors: parsedColors,
// danh_gia: Có thể là num hoặc null, cung cấp giá trị mặc định
rating: (json['danh_gia'] as num?)?.toDouble() ?? 0.0,
// so_luong_danh_gia: Có thể là int hoặc null, cung cấp giá trị mặc định
reviewCount: (json['so_luong_danh_gia'] as int?) ?? 0,
);
}
}