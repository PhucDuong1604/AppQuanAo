// lib/models/order.dart
import 'package:flutter/material.dart';

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}

enum OrderStatus {
  pending, // Đang chờ xác nhận
  processing, // Đang xử lý
  shipped, // Đã giao hàng
  delivered, // Đã hoàn thành
  cancelled, // Đã hủy
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Đang chờ xác nhận';
      case OrderStatus.processing:
        return 'Đang xử lý';
      case OrderStatus.shipped:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã hoàn thành';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.lightGreen;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

class Order {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final OrderStatus status;
  final List<OrderItem> items;
  final String? shippingAddress; // Có thể thêm thông tin địa chỉ giao hàng chi tiết

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.shippingAddress,
  });
}