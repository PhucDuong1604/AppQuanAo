import 'package:appquanao/screens/address_list_screen.dart';
import 'package:appquanao/screens/cart_screen.dart';
import 'package:appquanao/screens/order_list_screen.dart';
import 'package:appquanao/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appquanao/models/user_session.dart'; // Đảm bảo import UserSession
import 'package:appquanao/screens/login_screen.dart'; // Hoặc màn hình bắt đầu của bạn

void main() {
  runApp(
    // Đây là nơi bạn cung cấp UserSession cho toàn bộ ứng dụng
    ChangeNotifierProvider(
      create: (context) => UserSession(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Quần Áo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Màn hình khởi đầu của ứng dụng.
      // Nếu bạn muốn kiểm tra trạng thái đăng nhập ngay khi khởi động,
      // bạn có thể điều hướng dựa trên UserSession ở đây.
      home: Consumer<UserSession>(
        builder: (context, userSession, child) {
          // Nếu có currentUser, đi đến màn hình chính hoặc ProfileScreen
          // Ngược lại, đi đến LoginPage
          if (userSession.currentUser != null) {
            // Ví dụ: Nếu người dùng đã đăng nhập, chuyển đến ProfileScreen
            // Hoặc chuyển đến Home Screen nếu có
            return const ProfileScreen(); // Giả sử ProfileScreen là màn hình chính sau đăng nhập
          } else {
            return const LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      // Định nghĩa các routes khác
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfileScreen(), // Đảm bảo ProfileScreen có route
        '/addresses': (context) => const AddressListScreen(),
        '/orders': (context) => OrderListScreen(),
       '/cart': (context) => const CartScreen(), // Đảm bảo CartScreen được truy cập sau khi Providers đã có
        // ... các route khác
        // Thêm các routes khác của bạn
      },
    );
  }
}