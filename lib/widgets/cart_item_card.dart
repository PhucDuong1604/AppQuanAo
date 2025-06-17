
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appquanao/models/cart_item.dart'; // Import CartItem

// Helper function để lấy tên màu từ Color object
// Đặt hàm này ở đầu file, bên ngoài class CartItemCard
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
  return 'Không xác định'; // Mặc định cho Colors.transparent hoặc các màu không xác định
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onItemSelected;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    var media = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox chọn sản phẩm
          Checkbox(
            value: item.isSelected,
            onChanged: (bool? newValue) {
              if (newValue != null) {
                onItemSelected(newValue); // Gọi callback để toggle trạng thái
              }
            },
            activeColor: Colors.black,
          ),
          // Ảnh sản phẩm
          Container(
            height: 80,
            width: 80,
            child:  Image.asset("images/products/${item.product.imageUrl}"),
          
          ),
          const SizedBox(width: 16),
          // Thông tin sản phẩm và điều khiển số lượng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  // SỬA ĐỔI DÒNG NÀY ĐỂ SỬ DỤNG _getColorNameFromColor
                  '${item.selectedSize} / ${_getColorNameFromColor(item.selectedColor)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(item.product.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
                ),
                const SizedBox(height: 8),
                // Điều khiển số lượng và nút xóa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: item.quantity > 1
                              ? () => onQuantityChanged(item.quantity - 1)
                              : null, // Vô hiệu hóa nếu số lượng là 1
                        ),
                        Text(
                          item.quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => onQuantityChanged(item.quantity + 1),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}