// lib/screens/address_list_screen.dart
import 'package:flutter/material.dart';
import 'package:appquanao/models/address.dart'; // Import model Address
import 'package:appquanao/screens/add_edit_address_screen.dart'; // Import màn hình thêm/sửa địa chỉ

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  // Biến này giờ đây là mutable (không còn final)
  final List<Address> _addresses = [
    Address(
      name: 'Dương Trọng Phúc',
      phone: '0706398104',
      street: 'Ký Con',
      district: 'Quận 1',
      city: 'TP.HCM',
      isDefault: true,
    ),
    Address(
      name: 'Nguyễn Văn A',
      phone: '0901234567',
      street: 'Lê Lợi',
      district: 'Quận 5',
      city: 'TP.HCM',
      isDefault: false,
    ),
  ];

  // Hàm để thêm hoặc chỉnh sửa địa chỉ
  Future<void> _navigateToAddEditAddress({Address? existingAddress, int? index}) async {
    final result = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: existingAddress),
      ),
    );

    if (result != null) {
      setState(() {
        // Nếu có địa chỉ hiện có (chỉnh sửa)
        if (existingAddress != null && index != null) {
          _addresses[index] = result;
        } else {
          // Thêm địa chỉ mới
          _addresses.add(result);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existingAddress == null ? 'Đã thêm địa chỉ mới!' : 'Đã cập nhật địa chỉ!')),
      );
    }
  }

  // Hàm để xóa địa chỉ
  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _addresses.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa địa chỉ!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút thêm địa chỉ mới
          ElevatedButton.icon(
            onPressed: () => _navigateToAddEditAddress(), // Gọi hàm thêm địa chỉ
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Thêm địa chỉ mới',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey, width: 0.5),
              minimumSize: const Size(double.infinity, 50), // Chiều rộng tối đa
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Danh sách các địa chỉ
          if (_addresses.isEmpty)
            const Center(
              child: Text('Bạn chưa có địa chỉ nào.', style: TextStyle(fontSize: 16)),
            )
          else
            Column(
              children: List.generate(_addresses.length, (index) {
                final address = _addresses[index];
                return _buildAddressCard(context, address, index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text('SĐT: ${address.phone}', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 5),
            Text(
              '${address.street}, ${address.district}, ${address.city}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _navigateToAddEditAddress(existingAddress: address, index: index), // Gọi hàm chỉnh sửa
                  child: const Text('Chỉnh sửa', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _deleteAddress(index), // Gọi hàm xóa
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}