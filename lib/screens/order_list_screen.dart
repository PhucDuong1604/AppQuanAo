// lib/screens/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appquanao/models/order.dart';
import 'package:appquanao/screens/order_detail_screen.dart'; // Import màn hình chi tiết đơn hàng

class OrderListScreen extends StatelessWidget {
  // Dữ liệu đơn hàng giả định
  final List<Order> orders = [
    Order(
      id: 'ORD001',
      orderDate: DateTime(2024, 5, 20, 10, 30),
      totalAmount: 550000.0,
      status: OrderStatus.delivered,
      items: [
        OrderItem(name: 'Áo thun cotton trắng', quantity: 2, price: 150000),
        OrderItem(name: 'Quần jean slimfit xanh', quantity: 1, price: 250000),
      ],
      shippingAddress: 'Ký Con, Quận 1, TP.HCM',
    ),
    Order(
      id: 'ORD002',
      orderDate: DateTime(2024, 6, 1, 14, 00),
      totalAmount: 300000.0,
      status: OrderStatus.shipped,
      items: [
        OrderItem(name: 'Giày sneaker canvas đen', quantity: 1, price: 300000),
      ],
      shippingAddress: 'Lê Lợi, Quận 5, TP.HCM',
    ),
    Order(
      id: 'ORD003',
      orderDate: DateTime(2024, 6, 5, 9, 15),
      totalAmount: 180000.0,
      status: OrderStatus.pending,
      items: [
        OrderItem(name: 'Tất cổ ngắn 3 đôi', quantity: 1, price: 80000),
        OrderItem(name: 'Mũ lưỡi trai', quantity: 1, price: 100000),
      ],
      shippingAddress: 'Cách Mạng Tháng Tám, Quận 3, TP.HCM',
    ),
     Order(
      id: 'ORD004',
      orderDate: DateTime(2024, 5, 10, 11, 00),
      totalAmount: 400000.0,
      status: OrderStatus.cancelled,
      items: [
        OrderItem(name: 'Váy maxi hoa', quantity: 1, price: 400000),
      ],
      shippingAddress: 'Nguyễn Du, Quận 1, TP.HCM',
    ),
  ];

  OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử đơn hàng của bạn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          if (orders.isEmpty)
            const Center(
              child: Text('Bạn chưa có đơn hàng nào.', style: TextStyle(fontSize: 16)),
            )
          else
            Column(
              children: orders.map((order) => _buildOrderCard(context, order)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã đơn hàng: ${order.id}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(color: order.status.color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Ngày đặt: ${dateFormat.format(order.orderDate)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              'Tổng tiền: ${currencyFormat.format(order.totalAmount)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.w600)),
            // Hiển thị tối đa 2 sản phẩm và thêm "..." nếu nhiều hơn
            ...order.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2),
              child: Text('- ${item.name} x${item.quantity} (${currencyFormat.format(item.price)})',
                style: TextStyle(color: Colors.grey[800], fontSize: 13)),
            )).toList(),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: Text('... và ${order.items.length - 2} sản phẩm khác', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
              ),
            if (order.shippingAddress != null && order.shippingAddress!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Giao đến: ${order.shippingAddress}', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Điều hướng đến màn hình chi tiết đơn hàng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}