// lib/screens/order_detail_screen.dart
import 'package:appquanao/models/order_model.dart'; // Đảm bảo đúng đường dẫn
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black), // Đổi màu mũi tên back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thông tin cơ bản về đơn hàng ---
            _buildSectionTitle('Thông tin đơn hàng'),
            _buildInfoRow('Mã đơn hàng:', order.maDonHang ?? 'N/A'),
            _buildInfoRow(
              'Ngày đặt:',
              order.ngayDat != null ? dateFormat.format(order.ngayDat!) : 'N/A',
            ),
            _buildStatusRow('Trạng thái:', order.trangThaiDonHang),
            _buildInfoRow(
              'Tổng tiền hàng:',
              currencyFormat.format(order.tongTien ?? 0),
            ),
            _buildInfoRow(
              'Phí vận chuyển:',
              currencyFormat.format(order.phiVanChuyen ?? 0),
            ),
            _buildInfoRow(
              'Giảm giá:',
              '-' + currencyFormat.format(order.giamGia ?? 0), // Hiển thị giảm giá âm
              color: Colors.red,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              'Thành tiền:',
              currencyFormat.format(order.thanhTien ?? 0),
              isBold: true,
              color: Colors.red,
            ),
            const Divider(height: 30),

            // --- Thông tin sản phẩm ---
            _buildSectionTitle('Sản phẩm trong đơn hàng'),
            const SizedBox(height: 10),
            if (order.items.isEmpty)
              const Center(child: Text('Không có sản phẩm nào trong đơn hàng này.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sử dụng Image.network để hiển thị hình ảnh từ URL
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: item.hinhAnh != null && item.hinhAnh!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(item.hinhAnh!),
                                    fit: BoxFit.cover,
                                  )
                                : null, // Không có hình ảnh, không hiển thị gì
                          ),
                          child: (item.hinhAnh == null || item.hinhAnh!.isEmpty)
                              ? const Icon(Icons.image_outlined, color: Colors.grey, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.tenSanPham,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (item.kichCo != null && item.kichCo!.isNotEmpty)
                                Text(
                                  'Kích cỡ: ${item.kichCo}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              if (item.mauSac != null && item.mauSac!.isNotEmpty)
                                Text(
                                  'Màu sắc: ${item.mauSac}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Số lượng: ${item.soLuong}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đơn giá: ${currencyFormat.format(item.giaBan)}',
                                style: const TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(item.giaBan * item.soLuong),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const Divider(height: 30),

            // --- Thông tin giao hàng & thanh toán ---
            _buildSectionTitle('Thông tin giao hàng & thanh toán'),
            const SizedBox(height: 10),
            _buildInfoRow('Địa chỉ nhận hàng:', order.diaChiGiaoHang ?? 'Chưa cung cấp'),
            _buildInfoRow('Địa chỉ thanh toán:', order.diaChiThanhToan ?? 'Chưa cung cấp'),
            _buildInfoRow('Phương thức TT:', order.phuongThucThanhToan ?? 'N/A'),
            _buildInfoRow('Trạng thái TT:', order.trangThaiThanhToan ?? 'N/A'),
            if (order.maTheoDoi != null && order.maTheoDoi!.isNotEmpty)
              _buildInfoRow('Mã theo dõi:', order.maTheoDoi!),
            if (order.ghiChu != null && order.ghiChu!.isNotEmpty)
              _buildInfoRow('Ghi chú:', order.ghiChu!),
            const SizedBox(height: 20),

            // --- Các nút hành động (nếu có) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (order.trangThaiDonHang == OrderStatus.pending)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý hủy đơn hàng (gọi API)
                        _showCancelOrderDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Hủy đơn hàng'),
                    ),
                  ),
                if (order.trangThaiDonHang == OrderStatus.delivered)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý mua lại (thêm các sản phẩm vào giỏ hàng)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng mua lại đang được phát triển.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mua lại'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper cho các dòng thông tin
  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Tăng chiều rộng cố định cho label để chứa các nhãn dài hơn
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper cho dòng trạng thái với màu sắc động
  Widget _buildStatusRow(String label, OrderStatus status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Chiều rộng cố định cho label
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(color: status.color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper cho tiêu đề các phần
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Hàm hiển thị dialog xác nhận hủy đơn hàng
  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy đơn hàng'),
          content: Text('Bạn có chắc chắn muốn hủy đơn hàng ${order.maDonHang ?? order.id} không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Gọi API hủy đơn hàng ở đây
                print('Đang hủy đơn hàng ID: ${order.id}');
                Navigator.of(context).pop(); // Đóng dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang gửi yêu cầu hủy đơn hàng ${order.maDonHang ?? ''}...')),
                );
                // Sau khi hủy thành công, bạn có thể pop màn hình này hoặc cập nhật trạng thái
                // Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }
}