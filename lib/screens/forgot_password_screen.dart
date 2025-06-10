import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Đảm bảo đã import
import 'package:pin_code_fields/pin_code_fields.dart'; // Import thư viện pin_code_fields
import 'package:appquanao/screens/activate_account_screen.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _sendOTP() {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      Fluttertoast.showToast(msg: "Vui lòng nhập số điện thoại hợp lệ");
    } else {
      // TODO: Gửi OTP đến số điện thoại ở đây (gọi API hoặc Firebase Auth...)
      Fluttertoast.showToast(msg: "Mã OTP đã được gửi đến $phone");

      // Điều hướng đến màn hình nhập mã OTP
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OTPVerificationScreen(phone: phone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên mật khẩu"),
        automaticallyImplyLeading: false, 
        ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nhập số điện thoại để nhận mã OTP",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOTP,
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.black,
                 foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Gửi mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String phone;

  const OTPVerificationScreen({super.key, required this.phone});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  String currentOtp = ""; // Biến để lưu trữ mã OTP hiện tại

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (currentOtp.length == 4) { // Giả sử OTP có 6 chữ số
      // TODO: Thực hiện xác minh OTP với máy chủ hoặc Firebase
      Fluttertoast.showToast(msg: "Đang xác minh OTP: $currentOtp");
      print("Mã OTP đã nhập: $currentOtp");

      // Sau khi xác minh thành công, bạn có thể điều hướng đến màn hình đặt lại mật khẩu
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ActivateAccountScreen()));
    } else {
      Fluttertoast.showToast(msg: "Vui lòng nhập đủ 4 chữ số OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác minh OTP"),
        automaticallyImplyLeading: false, 
       /* leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),*/
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Canh giữa các widget
          children: [
            const SizedBox(height: 50), // Thêm khoảng trống ở trên
            Text(
              'Nhập mã OTP đã gửi đến ${widget.phone}',
              textAlign: TextAlign.center, // Canh giữa văn bản
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: PinCodeTextField(
                appContext: context,
                length: 4, // Số lượng ô (ví dụ OTP 6 chữ số)
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[200],
                  selectedFillColor: Colors.grey[300],
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blueAccent,
                ),
                cursorColor: Colors.black,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                controller: otpController,
                keyboardType: TextInputType.number,
                boxShadows: const [
                  BoxShadow(
                    offset: Offset(0, 1),
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
                onCompleted: (otp) {
                  // Được gọi khi người dùng nhập đủ số lượng ô
                  print("Mã OTP đã hoàn thành: $otp");
                  setState(() {
                    currentOtp = otp;
                  });
                  _verifyOtp(); // Tự động xác minh khi hoàn thành
                },
                onChanged: (value) {
                  // Được gọi mỗi khi giá trị thay đổi
                  setState(() {
                    currentOtp = value;
                  });
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black,
                 //foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Xác nhận OTP'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // TODO: Xử lý logic gửi lại OTP
                Fluttertoast.showToast(msg: "Yêu cầu gửi lại OTP cho ${widget.phone}");
              },
              child: const Text("Gửi lại mã OTP"),
            ),
          ],
        ),
      ),
    );
  }
}