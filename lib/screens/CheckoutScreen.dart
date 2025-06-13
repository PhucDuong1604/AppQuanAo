import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart'; // Đảm bảo đường dẫn đúng đến CartItem model
import '../models/product.dart'; // Đảm bảo đường dẫn đúng đến Product model (nếu cần)
import '../providers/cart_provider.dart'; // Đảm bảo đường dẫn đúng đến CartProvider
import 'momo_payment_screen.dart'; // Thêm import cho MomoPaymentScreen

enum PaymentMethod { cod, momo }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _recipientName = '';
  String _recipientPhone = '';
  String _recipientAddress = '';
  String _notes = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cod; // Mặc định COD

  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  // XÓA BỎ HOÀN TOÀN HÀM _getColorName(Color color) VÌ item.selectedColor đã là String
  // Hoặc nếu bạn muốn ánh xạ chuỗi màu từ DB thành tên hiển thị, bạn có thể sửa lại hàm này
  // Nhưng trong hầu hết các trường hợp, item.selectedColor đã đủ để hiển thị.

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> selectedCartItems = cartProvider.selectedItems;
    final double subtotal = cartProvider.totalSelectedAmount;

    // Tính toán phí giao hàng
    final double shippingFee = subtotal >= 300000 ? 0.0 : 19000.0;
    // Giảm giá VIP (giả định 5% nếu có) - Cần logic cụ thể hơn cho VIP
    final double vipDiscount = subtotal * 0.00; // Giả định không có giảm giá VIP mặc định

    final double totalAmount = subtotal + shippingFee - vipDiscount;

    // Xác định văn bản và màu sắc của nút Đặt hàng dựa trên phương thức thanh toán
    String orderButtonText;
    Color orderButtonColor;

    if (_selectedPaymentMethod == PaymentMethod.cod) {
      orderButtonText = 'ĐẶT HÀNG: GIAO HÀNG VÀ THU TIỀN TẬN NƠI';
      orderButtonColor = Colors.teal; // Màu xanh lam ban đầu
    } else { // PaymentMethod.momo
      orderButtonText = 'THANH TOÁN ${currencyFormatter.format(totalAmount).toUpperCase()}';
      orderButtonColor = Colors.teal; // Giữ màu xanh lam như hình ví dụ
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin giỏ hàng của bạn', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHI TIẾT ĐƠN HÀNG
            const Text(
              'CHI TIẾT ĐƠN HÀNG',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Divider(height: 20, thickness: 1),
            ...selectedCartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        // SỬA LẠI ĐIỀU KIỆN KIỂM TRA imageUrl CHO AN TOÀN
                        child: item.product.imageUrl.isNotEmpty
                            ? Image.network(
                                item.product.imageUrl, // Bỏ ! nếu imageUrl không phải là String?
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              // SỬA LỖI MÀU SẮC: DÙNG TRỰC TIẾP item.selectedColor (là String)
                              'Số lượng: ${item.quantity} - Size: ${item.selectedSize} - Màu: ${item.selectedColor}',
                            ),
                            Text(
                              currencyFormatter.format(item.product.price * item.quantity),
                              style: const TextStyle(color: Colors.red),
                            ),
                            if (vipDiscount > 0)
                              Text(
                                'Giảm thêm VIP: ${currencyFormatter.format(vipDiscount)}',
                                style: TextStyle(color: Colors.green[700], fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
            const Divider(height: 20, thickness: 1),
            // Phí giao hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Phí giao hàng:'),
                Text(currencyFormatter.format(shippingFee)),
              ],
            ),
            if (subtotal < 300000)
              Text(
                '(Miễn phí với đơn hàng trên ${currencyFormatter.format(300000)})',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            const SizedBox(height: 8),
            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  currencyFormatter.format(totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // THÔNG TIN NGƯỜI NHẬN
            const Text(
              'NGƯỜI NHẬN HÀNG',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Divider(height: 20, thickness: 1),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Tên'),
                    onChanged: (value) => _recipientName = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Điện thoại liên lạc'),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => _recipientPhone = value,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10), // Giới hạn tối đa 10 ký tự
                      FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      // Kiểm tra định dạng số điện thoại: đúng 10 số và bắt đầu bằng số 0
                      final phoneRegex = RegExp(r'^0[0-9]{9}$');
                      if (value.length != 10 || !phoneRegex.hasMatch(value)) {
                        return 'Số điện thoại không hợp lệ (phải có 10 số và bắt đầu bằng 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Địa chỉ'),
                    onChanged: (value) => _recipientAddress = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Ghi chú'),
                    maxLines: 3,
                    onChanged: (value) => _notes = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // PHƯƠNG THỨC THANH TOÁN
            const Text(
              'PHƯƠNG THỨC THANH TOÁN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Divider(height: 20, thickness: 1),
            RadioListTile<PaymentMethod>(
              title: const Text('Thanh toán khi nhận hàng [COD]'),
              value: PaymentMethod.cod,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Thanh toán bằng ví MoMo'),
              value: PaymentMethod.momo,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 30),

            // NÚT ĐẶT HÀNG
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedCartItems.isEmpty
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedPaymentMethod == PaymentMethod.momo) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MomoPaymentScreen(totalAmount: totalAmount),
                              ),
                            );
                            // Sau khi chuyển màn hình, bạn có thể cân nhắc xóa các sản phẩm đã chọn
                            // hoặc thực hiện sau khi xác nhận thanh toán thành công trên màn hình Momo.
                            // Ví dụ: cartProvider.removeSelectedItems();
                          } else {
                            // Xử lý thanh toán COD (hiển thị AlertDialog xác nhận)
                            _placeOrder(context, cartProvider, totalAmount);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orderButtonColor, // Sử dụng màu đã xác định
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  orderButtonText, // Sử dụng văn bản đã xác định
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Quay lại màn hình giỏ hàng
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Màu cam giống trong hình
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CÂN SẢN PHẨM KHÁC? CHỌN THÊM...',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý đặt hàng
  void _placeOrder(BuildContext context, CartProvider cartProvider, double finalTotal) {
    // Thu thập thông tin đặt hàng
    final orderDetails = {
      'recipientName': _recipientName,
      'recipientPhone': _recipientPhone,
      'recipientAddress': _recipientAddress,
      'notes': _notes,
      'paymentMethod': _selectedPaymentMethod.toString().split('.').last, // 'cod' hoặc 'momo'
      'items': cartProvider.selectedItems.map((item) => {
            'productId': item.product.id,
            'productName': item.product.name,
            'quantity': item.quantity,
            'selectedSize': item.selectedSize,
            'selectedColor': item.selectedColor, // SỬA LỖI MÀU SẮC: DÙNG TRỰC TIẾP item.selectedColor (là String)
            'pricePerItem': item.product.price,
            'totalPrice': item.product.price * item.quantity,
          }).toList(),
      'subtotal': cartProvider.totalSelectedAmount,
      // Đảm bảo shippingFee được tính đúng theo logic của bạn.
      // Tôi đã điều chỉnh lại một chút cho rõ ràng.
      'shippingFee': finalTotal - cartProvider.totalSelectedAmount + (cartProvider.totalSelectedAmount >= 300000 ? 0.0 : 19000.0),
      'totalAmount': finalTotal,
    };

    // Để demo, chúng ta sẽ chỉ hiển thị một thông báo thành công và xóa các sản phẩm đã chọn.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text(
          'Bạn có muốn thanh toán ${cartProvider.selectedItems.length} sản phẩm với tổng số tiền ${currencyFormatter.format(finalTotal)} bằng phương thức ${_selectedPaymentMethod == PaymentMethod.cod ? 'Tiền mặt khi nhận hàng' : 'MoMo'} không?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.removeSelectedItems(); // Xóa các sản phẩm đã thanh toán
              Navigator.of(ctx).pop(); // Đóng hộp thoại
              Navigator.of(context).pop(); // Quay lại màn hình giỏ hàng (hoặc trang chủ)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đơn hàng COD đã được đặt thành công!')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    // Trong một ứng dụng thực tế, bạn sẽ gửi orderDetails này đến backend của mình
    // print('Order Details: $orderDetails');
  }
}