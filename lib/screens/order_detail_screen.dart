// lib/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appquanao/models/order.dart'; // Import model Order

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black), // Đổi màu mũi tên back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cơ bản về đơn hàng
            _buildInfoRow('Mã đơn hàng:', order.id),
            _buildInfoRow('Ngày đặt:', dateFormat.format(order.orderDate)),
            _buildStatusRow('Trạng thái:', order.status),
            _buildInfoRow('Tổng tiền:', currencyFormat.format(order.totalAmount), isBold: true, color: Colors.red),
            const Divider(height: 30),

            // Thông tin sản phẩm
            const Text(
              'Sản phẩm:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true, // Quan trọng để ListView không bị lỗi trong Column/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200], // Ảnh sản phẩm
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: ${item.quantity}',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            Text(
                              'Giá: ${currencyFormat.format(item.price)}',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currencyFormat.format(item.price * item.quantity),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 30),

            // Thông tin giao hàng
            const Text(
              'Thông tin giao hàng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Địa chỉ nhận hàng:', order.shippingAddress ?? 'Chưa cung cấp'),
            // Bạn có thể thêm các thông tin khác như tên người nhận, SĐT nếu có trong model Order
            const SizedBox(height: 20),

            // Các nút hành động (nếu có)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (order.status == OrderStatus.pending)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý hủy đơn hàng
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hủy đơn hàng...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Hủy đơn hàng'),
                    ),
                  ),
                if (order.status == OrderStatus.delivered)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Xử lý mua lại
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mua lại đơn hàng...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mua lại'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Chiều rộng cố định cho label
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, OrderStatus status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Chiều rộng cố định cho label
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(color: status.color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}