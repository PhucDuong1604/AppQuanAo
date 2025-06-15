import 'package:appquanao/screens/cart_screen.dart';
import 'package:appquanao/screens/order_list_screen.dart';
import 'package:appquanao/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appquanao/models/user_session.dart'; // Đảm bảo import UserSession
import 'package:appquanao/screens/login_screen.dart'; // Hoặc màn hình bắt đầu của bạn
import 'package:appquanao/providers/cart_provider.dart'; // THÊM DÒNG NÀY: Import CartProvider
import 'package:appquanao/screens/home_screen.dart'; // THÊM DÒNG NÀY: Import HomePage nếu cần

void main() {
  runApp(
    // Sử dụng MultiProvider để cung cấp nhiều Providers cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserSession()),
        ChangeNotifierProvider(create: (context) => CartProvider()), // THÊM DÒNG NÀY: Cung cấp CartProvider
        // Thêm các Providers khác của bạn tại đây nếu có
      ],
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
      // Sử dụng Consumer để truy cập UserSession và quyết định màn hình ban đầu
      home: Consumer<UserSession>(
        builder: (context, userSession, child) {
          // Nếu có currentUser (đã đăng nhập), đi đến màn hình chính hoặc ProfileScreen
          // Ngược lại, đi đến LoginPage
          if (userSession.currentUser != null) {
            // Ví dụ: Nếu người dùng đã đăng nhập, chuyển đến HomePage hoặc ProfileScreen
            // Dòng này sẽ quyết định màn hình đầu tiên sau khi khởi động app
            return const HomePage(); // Đổi lại thành HomePage hoặc màn hình chính của bạn
          } else {
            return const LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      // Định nghĩa các routes khác
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfileScreen(),
        '/orders': (context) => OrderListScreen(),
        '/cart': (context) => const CartScreen(),
        // ... các route khác
      },
    );
  }
}