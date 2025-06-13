// appquanao/models/order_model.dart

import 'package:flutter/material.dart'; // Để dùng Color
import 'package:intl/intl.dart'; // Cần cho DateFormat nếu muốn parse ngày tháng chặt chẽ hơn

// Enum cho trạng thái đơn hàng để dễ quản lý màu sắc và tên hiển thị
enum OrderStatus {
  pending('Chờ xác nhận', Colors.orange),
  processing('Đang xử lý', Colors.blue),
  shipped('Đang giao', Colors.lightBlue),
  delivered('Đã giao', Colors.green),
  cancelled('Đã hủy', Colors.red),
  returned('Đã trả hàng', Colors.purple),
  unknown('Không xác định', Colors.grey);

  final String displayName;
  final Color color;

  const OrderStatus(this.displayName, this.color);

  // Factory để chuyển đổi từ chuỗi sang enum
  factory OrderStatus.fromString(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'cho_xac_nhan':
        return OrderStatus.pending;
      case 'dang_xu_ly':
        return OrderStatus.processing;
      case 'dang_giao':
        return OrderStatus.shipped;
      case 'da_giao':
        return OrderStatus.delivered;
      case 'da_huy':
        return OrderStatus.cancelled;
      case 'da_tra_hang':
        return OrderStatus.returned;
      default:
        return OrderStatus.unknown;
    }
  }
}

class OrderItem {
  final int chiTietId;
  final int sanPhamId;
  final String tenSanPham;
  final String? kichCo;
  final String? mauSac;
  final int soLuong;
  final double giaBan;
  final String? hinhAnh; // URL hình ảnh sản phẩm

  OrderItem({
    required this.chiTietId,
    required this.sanPhamId,
    required this.tenSanPham,
    this.kichCo,
    this.mauSac,
    required this.soLuong,
    required this.giaBan,
    this.hinhAnh,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      chiTietId: json['chi_tiet_id'] as int,
      sanPhamId: json['san_pham_id'] as int,
      tenSanPham: json['ten_san_pham'] as String,
      kichCo: json['kich_co'] as String?,
      mauSac: json['mau_sac'] as String?,
      soLuong: json['so_luong'] as int,
      giaBan: (json['gia_ban'] as num).toDouble(), // num có thể là int hoặc double
      hinhAnh: json['hinh_anh'] as String?,
    );
  }
}

class Order {
  final int id;
  final String? maDonHang;
  final int? nguoiDungId;
  final DateTime? ngayDat;
  final double? tongTien;
  final double? phiVanChuyen;
  final double? giamGia;
  final double? thanhTien;
  final String? diaChiGiaoHang;
  final String? diaChiThanhToan;
  final String? phuongThucThanhToan;
  final String? trangThaiThanhToan;
  final OrderStatus trangThaiDonHang; // Sử dụng enum OrderStatus
  final String? maTheoDoi;
  final String? ghiChu;
  final List<OrderItem> items; // Thêm danh sách các mặt hàng trong đơn

  Order({
    required this.id,
    this.maDonHang,
    this.nguoiDungId,
    this.ngayDat,
    this.tongTien,
    this.phiVanChuyen,
    this.giamGia,
    this.thanhTien,
    this.diaChiGiaoHang,
    this.diaChiThanhToan,
    this.phuongThucThanhToan,
    this.trangThaiThanhToan,
    required this.trangThaiDonHang,
    this.maTheoDoi,
    this.ghiChu,
    this.items = const [], // Khởi tạo rỗng mặc định
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse danh sách items
    // Lưu ý: Dữ liệu JSON bạn cung cấp không có trường 'items' trực tiếp trong đối tượng đơn hàng.
    // Nếu API của bạn thực sự KHÔNG trả về 'items' cùng với danh sách đơn hàng,
    // thì 'itemsList' sẽ là null, và 'parsedItems' sẽ là một danh sách rỗng, điều này ổn.
    // Tuy nhiên, nếu sau này bạn có một API khác để lấy chi tiết đơn hàng (có 'items' bên trong),
    // thì class Order này sẽ dùng được cho cả hai trường hợp.
    var itemsList = json['items'] as List?;
    List<OrderItem> parsedItems = itemsList != null
        ? itemsList.map((itemJson) => OrderItem.fromJson(itemJson)).toList()
        : [];

    return Order(
      id: json['id'] as int,
      maDonHang: json['ma_don_hang'] as String?,
      nguoiDungId: json['nguoi_dung_id'] as int?,
      // DateTime.tryParse() sẽ cố gắng parse và trả về null nếu không thành công
      // Định dạng "YYYY-MM-DD HH:mm:ss" thường được chấp nhận.
      ngayDat: json['ngay_dat'] != null && (json['ngay_dat'] is String)
          ? DateTime.tryParse(json['ngay_dat'])
          : null,
      tongTien: (json['tong_tien'] as num?)?.toDouble(),
      phiVanChuyen: (json['phi_van_chuyen'] as num?)?.toDouble(),
      giamGia: (json['giam_gia'] as num?)?.toDouble(),
      thanhTien: (json['thanh_tien'] as num?)?.toDouble(),
      diaChiGiaoHang: json['dia_chi_giao_hang'] as String?,
      diaChiThanhToan: json['dia_chi_thanh_toan'] as String?,
      phuongThucThanhToan: json['phuong_thuc_thanh_toan'] as String?,
      trangThaiThanhToan: json['trang_thai_thanh_toan'] as String?,
      trangThaiDonHang: OrderStatus.fromString(json['trang_thai_don_hang'] as String?),
      maTheoDoi: json['ma_theo_doi'] as String?,
      ghiChu: json['ghi_chu'] as String?,
      items: parsedItems,
    );
  }
}