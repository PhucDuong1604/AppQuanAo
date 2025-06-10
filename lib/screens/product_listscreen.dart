// product_listscreen.dart
import 'package:flutter/material.dart';

class ProductListScreen extends StatelessWidget {
  final String? category; // Thêm tham số category (nullable)

  const ProductListScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    String title = category ?? 'Tất cả sản phẩm'; // Hiển thị tên danh mục hoặc "Tất cả sản phẩm"

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đây là trang sản phẩm của danh mục: ${category ?? 'Tất cả sản phẩm'}',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            // Ở đây bạn sẽ hiển thị danh sách sản phẩm thực tế
            // Ví dụ: ListView.builder để hiển thị sản phẩm dựa trên 'category'
          ],
        ),
      ),
    );
  }
}