import 'package:flutter/foundation.dart';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => [..._orders]; // Trả về bản sao để tránh sửa đổi trực tiếp

  void addOrder(Order order) {
    _orders.insert(0, order); // Thêm đơn hàng mới vào đầu danh sách
    notifyListeners();
  }

  // Bạn có thể thêm các phương thức khác ở đây, ví dụ:
  // void updateOrderStatus(String orderId, OrderStatus newStatus) {
  //   final index = _orders.indexWhere((order) => order.id == orderId);
  //   if (index != -1) {
  //     _orders[index].status = newStatus;
  //     notifyListeners();
  //   }
  // }
}
