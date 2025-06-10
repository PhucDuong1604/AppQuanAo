import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <--- Thêm import này
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../screens/CheckoutScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _selectAll = true; // Trạng thái của checkbox "Chọn tất cả"

  @override
  void initState() {
    super.initState();
    // Đảm bảo trạng thái ban đầu của selectAll khớp với trạng thái thực tế của các item
    // Nếu có item nào không được chọn, _selectAll sẽ là false
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      _selectAll = cartProvider.items.every((item) => item.isSelected);
      setState(() {}); // Cập nhật UI sau khi lấy trạng thái ban đầu
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItems = cartProvider.items;

    // Tạo một NumberFormat để định dạng số có dấu phân cách hàng nghìn và đơn vị tiền tệ
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN', // Đặt locale cho tiếng Việt
      symbol: 'đ',     // Đơn vị tiền tệ Việt Nam Đồng
      decimalDigits: 0, // Không hiển thị phần thập phân
    );

    // Cập nhật trạng thái _selectAll nếu tất cả item đều được chọn hoặc không
    // Điều này giúp checkbox "Chọn tất cả" phản ứng đúng khi người dùng chọn/bỏ chọn từng item
    if (cartItems.isNotEmpty) {
      bool currentSelectAllStatus = cartItems.every((item) => item.isSelected);
      if (_selectAll != currentSelectAllStatus) {
        // Chỉ cập nhật nếu có sự thay đổi để tránh setState lặp lại không cần thiết
        // Cảnh báo: Việc setState trong build có thể dẫn đến vòng lặp vô hạn
        // nếu không được kiểm soát cẩn thận.
        // Cách tốt hơn là sử dụng Consumer hoặc Selector cho trạng thái này
        // hoặc gọi nó từ một callback khác.
        // Để đơn giản ví dụ, tôi đặt ở đây, nhưng cẩn thận với setState trong build.
        _selectAll = currentSelectAllStatus;
      }
    } else {
      _selectAll = false; // Nếu giỏ hàng trống, không chọn gì cả
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng của bạn', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Giỏ hàng của bạn đang trống!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tiếp tục mua sắm',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Checkbox "Chọn tất cả"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectAll,
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectAll = newValue;
                            });
                            cartProvider.toggleSelectAll(newValue);
                          }
                        },
                        activeColor: Colors.black,
                      ),
                      const Text('Chọn tất cả', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        Divider(indent: 20, endIndent: 20, color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        item: item,
                        onRemove: () => cartProvider.removeItem(item.product.id, item.selectedSize, item.selectedColor),
                        onQuantityChanged: (newQuantity) =>
                            cartProvider.updateItemQuantity(item.product.id, item.selectedSize, item.selectedColor, newQuantity),
                        onItemSelected: (isSelected) { // <--- XỬ LÝ SỰ KIỆN CHỌN TỪ CARTITEMCARD
                          cartProvider.toggleItemSelected(item.product.id, item.selectedSize, item.selectedColor);
                        },
                      );
                    },
                  ),
                ),
                // Thanh tổng tiền cố định ở dưới cùng
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tổng thanh toán\n${currencyFormatter.format(cartProvider.totalSelectedAmount)}', // <--- Đã sử dụng NumberFormat ở đây
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: cartProvider.selectedItems.isEmpty
                            ? null // Vô hiệu hóa nút nếu không có sản phẩm nào được chọn
                            : () {
                                // Điều hướng đến CheckoutScreen khi nhấn nút "Thanh toán"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckoutScreen(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Thanh toán',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Hàm _processPayment cũ đã được loại bỏ/chuyển logic sang CheckoutScreen
  // (Bạn có thể giữ lại nếu muốn xử lý các trường hợp khác)
}
