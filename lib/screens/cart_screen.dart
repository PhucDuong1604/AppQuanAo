import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart'; // Đảm bảo widget này tồn tại và được định nghĩa đúng
import '../screens/CheckoutScreen.dart'; // Đảm bảo màn hình này tồn tại

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Trạng thái của checkbox "Chọn tất cả" - KHÔNG NÊN LÀ STATE CỤC BỘ DỄ DẪN ĐẾN LỖI ĐỒNG BỘ
  // Thay vào đó, hãy đọc nó trực tiếp từ Provider hoặc dùng Selector.
  // bool _selectAll = true; // Bỏ biến này nếu bạn muốn đơn giản

  @override
  void initState() {
    super.initState();
    // Yêu cầu CartProvider tải giỏ hàng khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.fetchCartItems(); // Bắt đầu tải giỏ hàng
      // _selectAll = cartProvider.items.every((item) => item.isSelected); // Sẽ được tính lại trong build hoặc dùng Selector
      // setState(() {}); // Không cần setState ở đây nếu bạn đọc trực tiếp từ provider
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer hoặc Provider.of để lắng nghe CartProvider
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItems = cartProvider.items;

    // Tính trạng thái _selectAll DỰA TRÊN dữ liệu hiện tại của provider
    // Đây là cách an toàn để tránh setState trong build
    bool currentSelectAllStatus = cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);

    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

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
                      Navigator.pop(context); // Quay về màn hình trước
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
                        value: currentSelectAllStatus, // Sử dụng biến đã tính toán
                        onChanged: (bool? newValue) {
                          if (newValue != null) {
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
                        onItemSelected: (isSelected) {
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
                          'Tổng thanh toán\n${currencyFormatter.format(cartProvider.totalSelectedAmount)}',
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
}