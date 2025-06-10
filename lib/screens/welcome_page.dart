import 'package:flutter/material.dart';
import 'package:appquanao/screens/login_screen.dart';
import 'package:appquanao/screens/register_page.dart';
class FashionWelcomePage extends StatelessWidget {
  const FashionWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
     // backgroundColor: const Color.fromARGB(255, 95, 94, 94), // Màu nền hiện đại, bạn có thể đổida
      body: SafeArea(
        child: Stack(
          children: [
           Image.asset(
            'images/background.jpg', 
                  fit: BoxFit.cover,
                  height: media.height,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset('images/logo.png', // Đổi logo shop bạn
                  width: 150,
                ),

                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                       Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                    },
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nút khách hàng mới
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "Tôi là khách hàng mới",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
               
              ],
            ),

           
          ],
        ),
      ),
    );
  }
}
