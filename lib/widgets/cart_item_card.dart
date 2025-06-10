import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- Thêm import này
import '../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final Function(bool) onItemSelected; // <--- THÊM CALLBACK NÀY

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onItemSelected, // <--- THÊM VÀO CONSTRUCTOR
  }) : super(key: key);

  // Hàm trợ giúp để lấy tên màu từ đối tượng Color
  String _getColorName(Color color) {
    if (color == Colors.transparent) return 'Không màu';
    if (color == Colors.red) return 'Đỏ';
    if (color == Colors.blue) return 'Xanh dương';
    if (color == Colors.green) return 'Xanh lá';
    if (color == Colors.black) return 'Đen';
    if (color == Colors.white) return 'Trắng';
    if (color == Colors.grey) return 'Xám';
    if (color == Colors.yellow) return 'Vàng';
    if (color == Colors.orange) return 'Cam';
    if (color == Colors.purple) return 'Tím';
    if (color == Colors.pink) return 'Hồng';
    if (color == Colors.brown) return 'Nâu';
    if (color == Colors.cyan) return 'Xanh lơ';
    if (color == Colors.indigo) return 'Chàm';
    if (color == Colors.lime) return 'Xanh nõn chuối';
    if (color == Colors.amber) return 'Hổ phách';
    // Mở rộng thêm các màu khác nếu cần

    // Mặc định hiển thị mã hex nếu không tìm thấy tên màu
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    // Tạo một NumberFormat để định dạng số có dấu phân cách hàng nghìn
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN', // Đặt locale cho tiếng Việt
      symbol: 'đ',     // Đơn vị tiền tệ Việt Nam Đồng
      decimalDigits: 0, // Không hiển thị phần thập phân
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox để chọn sản phẩm
            Checkbox( // <--- THÊM CHECKBOX
              value: item.isSelected,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  onItemSelected(newValue); // Gọi callback khi trạng thái thay đổi
                }
              },
              activeColor: Colors.black, // Màu khi checkbox được chọn
            ),
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty)
                  ? Image.network(
                      item.product.imageUrl!,
                      width: 40, // Đã thay đổi kích thước ảnh
                      height: 40, // Đã thay đổi kích thước ảnh
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                        );
                      },
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded( // <--- Expanded này đã đúng chỗ
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Hiển thị size và color
                  if (item.selectedSize != 'N/A' || item.selectedColor != Colors.transparent)
                    Text(
                      'Size: ${item.selectedSize} - Màu: ${_getColorName(item.selectedColor)}', // <--- Đã sử dụng hàm _getColorName ở đây
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 8),
                  // Giá và số lượng
                  Row(
                    children: [
                      // Giá sản phẩm
                      Expanded( // <--- Đã thêm Expanded ở đây để giá tiền tự động điều chỉnh kích thước
                        child: Text(
                          currencyFormatter.format(item.product.price), // <--- Đã sử dụng NumberFormat ở đây
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      // Điều chỉnh số lượng
                      Row( // Giữ nguyên Row này để nhóm các nút và số lượng
                        mainAxisSize: MainAxisSize.min, // Giúp Row chỉ chiếm không gian cần thiết
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              } 
                            },
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              onQuantityChanged(item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Nút xóa
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
