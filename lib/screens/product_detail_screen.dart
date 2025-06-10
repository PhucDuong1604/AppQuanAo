import 'package:flutter/material.dart';
import 'package:appquanao/models/product.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:appquanao/providers/cart_provider.dart'; // Import CartProvider
import 'package:appquanao/screens/cart_screen.dart'; // Để điều hướng đến trang giỏ hàng

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColorName; // Lưu tên màu (String) đã chọn
  Color? _selectedColorObject; // Lưu đối tượng Color đã chọn

  @override
  void initState() {
    super.initState();
    // Đặt giá trị mặc định cho size và color nếu có sẵn
   
    if (widget.product.colors.isNotEmpty) {
      _selectedColorName = widget.product.colors.first;
      _selectedColorObject = _getColorFromString(_selectedColorName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chia sẻ sản phẩm')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thêm vào yêu thích')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.product.imageUrl),
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
                    widget.product.name,
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
                        '${widget.product.rating}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${widget.product.reviewCount} đánh giá)',
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
                        '${widget.product.price.toStringAsFixed(0)}đ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      if (widget.product.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${widget.product.oldPrice!.toStringAsFixed(0)}đ',
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
                  if (widget.product.sizes.isNotEmpty) ...[
                    const Text(
                      'Kích thước:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.product.sizes.map((size) {
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
                  if (widget.product.colors.isNotEmpty) ...[
                    const Text(
                      'Màu sắc:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.product.colors.map((colorName) {
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
                    widget.product.description,
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
              icon: const Icon(Icons.chat_bubble_outline, size: 28, color: Colors.blueAccent),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat với người bán')),
                );
              },
            ),
            // Nút giỏ hàng trên AppBar, giờ điều hướng đến CartScreen
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
                  // Lấy instance của CartProvider
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);

                  // Kiểm tra xem người dùng đã chọn đủ size và màu chưa (nếu sản phẩm có các tùy chọn này)
                  if (widget.product.sizes.isNotEmpty && _selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn kích thước')),
                    );
                    return; // Dừng lại nếu chưa chọn size
                  }
                  if (widget.product.colors.isNotEmpty && _selectedColorObject == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn màu sắc')),
                    );
                    return; // Dừng lại nếu chưa chọn màu
                  }

                  // Thêm sản phẩm vào giỏ hàng thông qua CartProvider
                  cartProvider.addItem(
                    widget.product,
                    _selectedSize ?? 'N/A', // Truyền size đã chọn (hoặc 'N/A' nếu không có size)
                    _selectedColorObject ?? Colors.transparent, // Truyền màu đã chọn (hoặc transparent nếu không có màu)
                  );

                  // Hiển thị thông báo đã thêm sản phẩm
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm ${widget.product.name} (Size: ${_selectedSize ?? 'N/A'}, Màu: ${_selectedColorName ?? 'N/A'}) vào giỏ hàng!'),
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