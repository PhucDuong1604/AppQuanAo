import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:appquanao/models/user_session.dart';
import 'package:appquanao/models/order_model.dart';
import 'package:appquanao/screens/order_detail_screen.dart'; // Import màn hình chi tiết đơn hàng

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Tải đơn hàng khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  // Hàm tải danh sách đơn hàng từ API
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Reset lỗi trước khi tải mới
    });

    final userSession = Provider.of<UserSession>(context, listen: false);
    final userId = userSession.currentUser?.id;

    if (userId == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.';
        _isLoading = false;
      });
      print('Lỗi: ID người dùng là null khi tải đơn hàng.');
      return;
    }

    // Đảm bảo URL API của bạn là chính xác và có thể truy cập được
    // Sử dụng địa chỉ IP thực tế của máy chủ thay vì localhost nếu chạy trên thiết bị vật lý
    final Uri uri = Uri.parse('http://10.0.2.2/apiAppQuanAo/api/donhang/danhsachdonhang.php?nguoi_dung_id=$userId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is List) {
          // Nếu API trả về một mảng các đơn hàng
          setState(() {
            _orders = responseData.map((json) => Order.fromJson(json)).toList();
            _isLoading = false;
          });
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          // Nếu API trả về thông báo lỗi hoặc không có đơn hàng (ví dụ: "Không tìm thấy đơn hàng...")
          setState(() {
            _errorMessage = responseData['message'];
            _isLoading = false;
          });
          print('API Response message: ${responseData['message']}');
        } else {
          // Trường hợp phản hồi API không đúng định dạng mong đợi
          setState(() {
            _errorMessage = 'Dữ liệu đơn hàng không hợp lệ.';
            _isLoading = false;
          });
          print('Dữ liệu API không đúng định dạng: ${response.body}');
        }
      } else {
        // Xử lý các mã trạng thái HTTP không thành công (ví dụ: 404, 500)
        setState(() {
          _errorMessage = 'Lỗi máy chủ: ${response.statusCode}. Vui lòng thử lại.';
          _isLoading = false;
        });
        print('Lỗi API Status Code: ${response.statusCode}');
        print('API Response Body: ${response.body}');
      }
    } catch (e) {
      // Xử lý lỗi kết nối mạng (ví dụ: không có internet, địa chỉ IP sai)
      setState(() {
       _errorMessage = 'Lỗi kết nối: Không thể tải đơn hàng. Vui lòng kiểm tra mạng và thử lại.';
       _isLoading = false;
      });
      print("Lỗi kết nối chi tiết khi tải đơn hàng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị vòng tròn tải
          : _errorMessage.isNotEmpty
              ? Center( // Hiển thị lỗi và nút thử lại
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('Bạn chưa có đơn hàng nào.')) // Khi không có đơn hàng
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: InkWell( // Bọc trong InkWell để có hiệu ứng nhấn
                            onTap: () {
                              // Điều hướng đến màn hình chi tiết đơn hàng
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailScreen(order: order),
                                ),
                              ).then((_) {
                                // Tải lại danh sách đơn hàng khi quay về từ màn hình chi tiết
                                // để cập nhật trạng thái nếu có thay đổi (ví dụ: hủy đơn hàng)
                                _fetchOrders();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mã đơn hàng: ${order.maDonHang ?? 'N/A'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ngày đặt: ${order.ngayDat != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.ngayDat!) : 'N/A'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tổng tiền: ${currencyFormat.format(order.thanhTien ?? 0)}', // Hiển thị thành tiền cuối cùng
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  // Hiển thị trạng thái bằng displayName và color từ enum
                                  Row(
                                    children: [
                                      const Text(
                                        'Trạng thái: ',
                                        style: TextStyle(fontSize: 15, color: Colors.grey),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: order.trangThaiDonHang.color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          order.trangThaiDonHang.displayName,
                                          style: TextStyle(
                                            color: order.trangThaiDonHang.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        // Điều hướng đến màn hình chi tiết đơn hàng (lặp lại logic của InkWell)
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderDetailScreen(order: order),
                                          ),
                                        ).then((_) {
                                          _fetchOrders();
                                        });
                                      },
                                      child: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}