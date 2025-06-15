/*import 'package:flutter/foundation.dart'; // Import for debugPrint

class Product {
  final String id;
  final String code;
  final String name;
  final String imageUrl;
  final double price;
  final double? oldPrice; // oldPrice có thể null, nên dùng double?
  final String description;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.oldPrice, // Không bắt buộc
    required this.description,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.sizes,
    required this.colors,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Debug print để xem dữ liệu JSON của một sản phẩm cụ thể
    debugPrint('Parsing product JSON: $json');

    // Helper function to safely parse double
    double _parseDouble(dynamic value) {
      if (value == null) {
        return 0.0; // Hoặc giá trị mặc định khác nếu thích
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        // Cố gắng parse chuỗi thành double. Nếu lỗi, trả về 0.0 hoặc ném lỗi tùy ý
        try {
          return double.parse(value);
        } catch (e) {
          debugPrint('Error parsing double from string "$value": $e');
          return 0.0; // Fallback value
        }
      }
      return 0.0; // Fallback value for other types
    }

    // Helper function to safely parse optional double
    double? _parseOptionalDouble(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          debugPrint('Error parsing optional double from string "$value": $e');
          return null; // Fallback value for optional
        }
      }
      return null; // Fallback value for other types
    }

    return Product(
      id: json["id_sanpham"]?.toString() ?? '', // Chắc chắn là String
      code: json["ma_san_pham"] ?? '',
      name: json["ten_sanpham"] ?? '',
      imageUrl: json["hinh_anh"] ?? "https://via.placeholder.com/150",
      price: _parseDouble(json["gia"]), // Sử dụng helper function
      oldPrice: _parseOptionalDouble(json["gia_cu"]), // Sử dụng helper function
      description: json["mo_ta"] ?? '',
      category: json["category"] ?? "Chưa phân loại",
      rating: _parseDouble(json["danh_gia"]), // Sử dụng helper function
      reviewCount: (json["so_luong_danh_gia"] is int)
          ? json["so_luong_danh_gia"]
          : int.tryParse(json["so_luong_danh_gia"]?.toString() ?? '0') ?? 0,
      sizes: (json["kich_thuoc"] is String && json["kich_thuoc"].isNotEmpty)
          ? json["kich_thuoc"].split(',') // Chắc chắn là List<String>
          : [],
      colors: (json["mau_sac"] is String && json["mau_sac"].isNotEmpty)
          ? json["mau_sac"].split(',') // Chắc chắn là List<String>
          : [],
    );
  }
}*/
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/material.dart'; // Import for Color if you're using it in Product model

class Product {
  final String id;
  final String code;
  final String name;
  final String imageUrl;
  final double price;
  final double? oldPrice; // oldPrice có thể null, nên dùng double?
  final String description;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> sizes;
  final List<String> colors; // Vẫn giữ List<String> cho Product model

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.oldPrice, // Không bắt buộc
    required this.description,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.sizes,
    required this.colors,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Debug print để xem dữ liệu JSON của một sản phẩm cụ thể
    debugPrint('Parsing product JSON in Product.fromJson: $json');

    // Helper function to safely parse double
    double _parseDouble(dynamic value) {
      if (value == null) {
        return 0.0;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          debugPrint('Error parsing double from string "$value": $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    // Helper function to safely parse optional double
    double? _parseOptionalDouble(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          debugPrint('Error parsing optional double from string "$value": $e');
          return null;
        }
      }
      return null;
    }

    // Helper function to parse list of strings from a comma-separated string
    List<String> _parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }


    return Product(
      // Ưu tiên các key từ API giỏ hàng, nếu không có thì dùng các key khác
      id: json["san_pham_id"]?.toString() ?? json["id_sanpham"]?.toString() ?? '',
      code: json["ma_san_pham"]?.toString() ?? '',
      name: json["ten_san_pham"]?.toString() ?? json["ten_sanpham"]?.toString() ?? '', // Sửa key ưu tiên
      imageUrl: json["anh_chinh_url"]?.toString() ?? json["hinh_anh"]?.toString() ?? "https://placehold.co/150", // Sửa key ưu tiên và fallback URL
      price: _parseDouble(json["gia"]), // Sử dụng key "gia"
      oldPrice: _parseOptionalDouble(json["gia_giam"] ?? json["gia_cu"]), // Ưu tiên "gia_giam"
      description: json["mo_ta"]?.toString() ?? '',
      category: json["category"]?.toString() ?? "Chưa phân loại",
      rating: _parseDouble(json["danh_gia"]),
      reviewCount: (json["so_luong_danh_gia"] is int)
          ? json["so_luong_danh_gia"]
          : int.tryParse(json["so_luong_danh_gia"]?.toString() ?? '0') ?? 0,
      sizes: _parseStringList(json["kich_co"] ?? json["kich_thuoc"]), // Ưu tiên "kich_co"
      colors: _parseStringList(json["mau_sac"]), // Sử dụng key "mau_sac"
    );
  }
}