import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../screens/CheckoutScreen.dart';

// Đảm bảo import UserSession từ đúng đường dẫn
import '../models/user_session.dart'; // Đã xác nhận đường dẫn này qua ProfileScreen


class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // LẤY USER ID TỪ UserSession CỦA BẠN
      // Sử dụng UserSession là provider quản lý phiên người dùng
      final userSession = Provider.of<UserSession>(context, listen: false); 
      
      // Truy cập currentUser từ UserSession, sau đó lấy 'id' của User
     final String? userId = userSession.currentUser?.id?.toString(); // GIẢ ĐỊNH class User CÓ thuộc tính 'id'

      if (userId != null) {
        cartProvider.fetchCartItems(userId); // <-- TRUYỀN userId VÀO ĐÂY
      } else {
        // Xử lý trường hợp không có userId (người dùng chưa đăng nhập hoặc lỗi)
        debugPrint('Lỗi: User ID là null. Người dùng chưa đăng nhập hoặc có lỗi.');
        // Bạn có thể hiển thị một SnackBar, AlertDialog, hoặc chuyển hướng đến màn hình đăng nhập.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để xem giỏ hàng của bạn.')),
        );
        // Tùy chọn: Điều hướng về màn hình đăng nhập nếu userId là null
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginPage()), // Đảm bảo LoginPage được import
        //   (Route<dynamic> route) => false,
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final List<CartItem> cartItems = cartProvider.items;

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
      body: cartProvider.isLoading // THÊM KIỂM TRA TRẠNG THÁI TẢI
          ? const Center(child: CircularProgressIndicator()) // Hiển thị vòng tròn tải nếu đang tải
          : cartItems.isEmpty
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
                            value: currentSelectAllStatus,
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

                          // !!!!!!!!!!! THÊM KIỂM TRA AN TOÀN Ở ĐÂY !!!!!!!!!!!
                          // Đảm bảo item.product không phải là null hoặc lỗi Product mặc định
                          if (item.product.id == 'error_id') { // Giả định 'error_id' là ID mặc định cho sản phẩm lỗi
                            debugPrint('Lỗi: Một CartItem có product.id là "error_id". Item: ${item.product.name}');
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Sản phẩm "${item.product.name}" không thể tải thông tin. Vui lòng thử lại.',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          }
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