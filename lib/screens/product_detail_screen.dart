import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:appquanao/models/product.dart';
import 'package:appquanao/providers/cart_provider.dart';
import 'package:appquanao/screens/cart_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColorName; // Giữ lại để hiển thị thông báo
  Color? _selectedColorObject; // Đây là đối tượng Color bạn muốn truyền
  int _quantity = 1;
  late Future<Product> _productDetailFuture;
  Product? _loadedProduct; // Thêm biến này để lưu trữ sản phẩm đã tải

  @override
  void initState() {
    super.initState();
    _productDetailFuture = _fetchProductDetails(widget.productId);
  }

  Future<Product> _fetchProductDetails(String productId) async {
    // !! Quan trọng: Đảm bảo YOUR_API_BASE_URL là URL API thực tế của bạn !!
     final response = await http.get(Uri.parse('http://10.0.2.2/apiAppQuanAo/api/chitietsanpham.php?id=${widget.productId}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final product = Product.fromJson(data);

      if (mounted) { // Kiểm tra nếu widget vẫn còn được gắn vào cây widget
        setState(() {
          _loadedProduct = product; // Gán sản phẩm đã tải vào biến trạng thái
          if (product.sizes.isNotEmpty && _selectedSize == null) {
            _selectedSize = product.sizes.first;
          }
          if (product.colors.isNotEmpty && _selectedColorName == null) {
            _selectedColorName = product.colors.first;
            _selectedColorObject = _getColorFromString(_selectedColorName!);
          }
        });
      }
      return product;
    } else {
      throw Exception('Failed to load product details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
       
      ),
      body: FutureBuilder<Product>(
        future: _productDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final Product product = snapshot.data!;
            // Dữ liệu đã được gán vào _loadedProduct trong _fetchProductDetails
            // nên không cần gán lại ở đây.
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // print('Error loading image: $exception');
                        },
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: const [],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber[400], size: 20),
                            const SizedBox(width: 5),
                            Text(
                              '${product.rating}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '(${product.reviewCount} đánh giá)',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            if (product.oldPrice != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                '${product.oldPrice!.toStringAsFixed(0)}đ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (product.sizes.isNotEmpty) ...[
                          const Text(
                            'Kích thước:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: product.sizes.map((size) {
                              bool isSelected = _selectedSize == size;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blueAccent : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.blueAccent : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (product.colors.isNotEmpty) ...[
                          const Text(
                            'Màu sắc:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: product.colors.map((colorName) {
                              bool isSelected = _selectedColorName == colorName;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColorName = colorName;
                                    _selectedColorObject = _getColorFromString(colorName);
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getColorFromString(colorName),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 30),
                        _buildDetailSection(Icons.delivery_dining, 'Vận chuyển', 'Giao hàng toàn quốc trong 2-5 ngày.'),
                        _buildDetailSection(Icons.policy, 'Chính sách đổi trả', 'Đổi trả miễn phí trong 7 ngày.'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Không có dữ liệu sản phẩm.'));
          }
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'đỏ':
        return Colors.red;
      case 'xanh':
        return Colors.blue;
      case 'đen':
        return Colors.black;
      case 'trắng':
        return Colors.white;
      case 'vàng':
        return Colors.yellow;
      case 'xám':
        return Colors.grey;
      case 'cam':
        return Colors.orange;
      case 'tím':
        return Colors.purple;
      case 'nâu':
        return Colors.brown;
      case 'hồng':
        return Colors.pink;
      case 'xanh lá':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildDetailSection(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 34.0),
            child: Text(
              content,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
          
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 28, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final product = _loadedProduct;

                  if (product == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dữ liệu sản phẩm chưa tải xong.')),
                    );
                    return;
                  }

                  final cartProvider = Provider.of<CartProvider>(context, listen: false);

                  if (product.sizes.isNotEmpty && _selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn kích thước')),
                    );
                    return;
                  }
                  if (product.colors.isNotEmpty && _selectedColorObject == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn màu sắc')),
                    );
                    return;
                  }

                  // Đã cập nhật để truyền đúng tham số
                  cartProvider.addItem(
                    product,
                    _selectedSize ?? 'N/A',
                    _selectedColorObject ?? Colors.transparent,
                    _quantity,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ${product.name} (Size: ${_selectedSize ?? 'N/A'}, Màu: ${_selectedColorName ?? 'N/A'}) vào giỏ hàng!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}