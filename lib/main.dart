import 'package:appquanao/Models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appquanao/providers/cart_provider.dart';
import 'package:appquanao/providers/order_provider.dart'; // Thêm import này
import 'package:appquanao/screens/welcome_page.dart'; // Giả định đây là màn hình chính của bạn

void main() {
  runApp(  // Sử dụng MultiProvider để cung cấp nhiều Provider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserSession()),
        ChangeNotifierProvider(create: (context) => CartProvider()), // <<< THÊM DÒNG NÀY
      ],
      child: const MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Sử dụng MultiProvider để cung cấp nhiều Provider
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()), // Đảm bảo dòng này đã được thêm
      ],
      child: MaterialApp(
        title: 'App Quần Áo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const FashionWelcomePage(), // Trang chủ của ứng dụng
           debugShowCheckedModeBanner: false,
        // Nếu bạn đang sử dụng Named Routes, hãy đảm bảo OrderListScreen được định nghĩa đúng cách
        // Ví dụ:
        // routes: {
        //   '/orders': (context) => const OrderListScreen(),
        // },
      ),
    );
  }
}