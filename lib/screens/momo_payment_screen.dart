import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For the timer

class MomoPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId; // Mock order ID for display purposes

  const MomoPaymentScreen({
    Key? key,
    required this.totalAmount,
    this.orderId = 'QO20250610092628u...', // ID đặt hàng giả định
  }) : super(key: key);

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  late Timer _timer;
  int _start = 60 * 10; // 10 phút tính bằng giây
  String _timeRemaining = '10:00';

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _timeRemaining = 'Hết hạn';
          });
        } else {
          setState(() {
            _start--;
            int minutes = _start ~/ 60;
            int seconds = _start % 60;
            _timeRemaining = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // Đã thêm SingleChildScrollView để cuộn toàn bộ nội dung
        child: Column( // Đã thay đổi từ Row sang Column
          children: [
            // Top Section: Order Information
            Padding( // Không cần Expanded ở đây vì nó là phần trên cùng của SingleChildScrollView
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Nhà cung cấp', 'TPShop'),
                  _buildInfoRow('Mã đơn hàng', widget.orderId),
                  _buildInfoRow('Mô tả', 'Thanh toán qua Momo'),
                  _buildInfoRow('Số tiền', currencyFormatter.format(widget.totalAmount)),
                  const SizedBox(height: 30),
                  Text(
                    'Đơn hàng sẽ hết hạn sau:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTimeBox(_timeRemaining.split(':')[0], 'Phút'),
                      const SizedBox(width: 10),
                      _buildTimeBox(_timeRemaining.split(':')[1], 'Giây'),
                    ],
                  ),
                  const SizedBox(height: 20), // Thêm khoảng cách giữa 2 phần
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Quay về màn hình trước (màn hình thanh toán)
                      },
                      child: const Text(
                        'Quay về',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section: QR Code Payment
            Container( // Không cần Expanded ở đây vì nó là phần dưới cùng của SingleChildScrollView
              color: Colors.pink[50], // Màu hồng nhạt của Momo
              padding: const EdgeInsets.all(16.0),
              width: double.infinity, // Đảm bảo chiếm toàn bộ chiều rộng
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quét mã QR để thanh toán',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'images/QR.jpg', // Placeholder for Momo QR
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 250,
                          height: 250,
                          color: Colors.grey[200],
                          child: Icon(Icons.qr_code_2, size: 100, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sử dụng App MoMo hoặc ứng dụng',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'ngân hàng để quét mã',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Logic để xem hướng dẫn
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng "Xem Hướng dẫn" sẽ được thêm vào sau.')),
                      );
                    },
                    child: const Text(
                      'Gặp khó khăn khi thanh toán? Xem Hướng dẫn',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String time, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink[100],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            time,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
