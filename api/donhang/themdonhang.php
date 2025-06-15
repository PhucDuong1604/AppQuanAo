<?php
header("Content-Type: application/json"); // Đặt Content-Type là JSON
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác

// Chỉ chấp nhận yêu cầu POST cho việc tạo đơn hàng mới
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận POST."));
    exit();
}

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Bắt đầu một giao dịch (transaction) để đảm bảo tính toàn vẹn dữ liệu
// Nếu có bất kỳ lỗi nào xảy ra, tất cả các thay đổi sẽ được rollback
mysqli_begin_transaction($conn);

try {
    // Lấy dữ liệu từ body của yêu cầu POST
    $input = json_decode(file_get_contents("php://input"), true);

    // Kiểm tra các trường bắt buộc cho bảng don_hang
    if (
        !isset($input['nguoi_dung_id']) ||
        !isset($input['tong_tien']) ||
        !isset($input['dia_chi_giao_hang']) ||
        !isset($input['phuong_thuc_thanh_toan']) ||
        !isset($input['items']) || !is_array($input['items']) || count($input['items']) === 0
    ) {
        echo json_encode(array("message" => "Vui lòng cung cấp đủ thông tin đơn hàng: nguoi_dung_id, tong_tien, dia_chi_giao_hang, phuong_thuc_thanh_toan, và ít nhất một 'items' (chi tiết đơn hàng)."));
        mysqli_rollback($conn); // Hoàn tác giao dịch
        exit();
    }

    // Gán dữ liệu cho các biến
    $nguoiDungId = $input['nguoi_dung_id'];
    $tongTien = $input['tong_tien'];
    $phiVanChuyen = isset($input['phi_van_chuyen']) ? $input['phi_van_chuyen'] : 0;
    $giamGia = isset($input['giam_gia']) ? $input['giam_gia'] : 0;
    $diaChiGiaoHang = $input['dia_chi_giao_hang'];
    $diaChiThanhToan = isset($input['dia_chi_thanh_toan']) ? $input['dia_chi_thanh_toan'] : $diaChiGiaoHang; // Mặc định giống địa chỉ giao hàng
    $phuongThucThanhToan = $input['phuong_thuc_thanh_toan'];
    $trangThaiThanhToan = isset($input['trang_thai_thanh_toan']) ? $input['trang_thai_thanh_toan'] : 'cho_xu_ly';
    $trangThaiDonHang = isset($input['trang_thai_don_hang']) ? $input['trang_thai_don_hang'] : 'cho_xu_ly';
    $maTheoDoi = isset($input['ma_theo_doi']) ? $input['ma_theo_doi'] : null;
    $ghiChu = isset($input['ghi_chu']) ? $input['ghi_chu'] : null;
    $items = $input['items'];

    // Tính toán thanh_tien (nếu không được cung cấp hoặc để đảm bảo tính đúng đắn)
    // Hoặc bạn có thể yêu cầu client gửi lên trường này.
    $thanhTien = $tongTien + $phiVanChuyen - $giamGia;

    // Tạo mã đơn hàng duy nhất (ví dụ: ORDER-YYYYMMDD-HHMMSS-RANDOM)
    $maDonHang = 'ORDER-' . date('Ymd-His') . '-' . uniqid();

    // 1. Chèn dữ liệu vào bảng don_hang
    $sqlInsertOrder = "INSERT INTO don_hang (
        ma_don_hang, nguoi_dung_id, tong_tien, phi_van_chuyen, giam_gia, thanh_tien,
        dia_chi_giao_hang, dia_chi_thanh_toan, phuong_thuc_thanh_toan,
        trang_thai_thanh_toan, trang_thai_don_hang, ma_theo_doi, ghi_chu
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmtOrder = mysqli_prepare($conn, $sqlInsertOrder);
    if ($stmtOrder === false) {
        throw new Exception("Lỗi chuẩn bị truy vấn đơn hàng: " . mysqli_error($conn));
    }

    // s: ma_don_hang, i: nguoi_dung_id, d: tong_tien, d: phi_van_chuyen, d: giam_gia, d: thanh_tien
    // s: dia_chi_giao_hang, s: dia_chi_thanh_toan, s: phuong_thuc_thanh_toan,
    // s: trang_thai_thanh_toan, s: trang_thai_don_hang, s: ma_theo_doi, s: ghi_chu
    mysqli_stmt_bind_param(
        $stmtOrder,
        "sidddssssssss",
        $maDonHang,
        $nguoiDungId,
        $tongTien,
        $phiVanChuyen,
        $giamGia,
        $thanhTien,
        $diaChiGiaoHang,
        $diaChiThanhToan,
        $phuongThucThanhToan,
        $trangThaiThanhToan,
        $trangThaiDonHang,
        $maTheoDoi,
        $ghiChu
    );

    if (!mysqli_stmt_execute($stmtOrder)) {
        throw new Exception("Lỗi khi tạo đơn hàng: " . mysqli_stmt_error($stmtOrder));
    }
    $donHangId = mysqli_insert_id($conn); // Lấy ID của đơn hàng vừa tạo
    mysqli_stmt_close($stmtOrder);

    // 2. Chèn dữ liệu vào bảng chi_tiet_don_hang
    $sqlInsertOrderItem = "INSERT INTO chi_tiet_don_hang (don_hang_id, san_pham_id, thuoc_tinh_id, so_luong, don_gia, gia_giam, tong_gia) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmtOrderItem = mysqli_prepare($conn, $sqlInsertOrderItem);
    if ($stmtOrderItem === false) {
        throw new Exception("Lỗi chuẩn bị truy vấn chi tiết đơn hàng: " . mysqli_error($conn));
    }

    foreach ($items as $item) {
        // Kiểm tra các trường bắt buộc cho chi tiết đơn hàng
        if (
            !isset($item['san_pham_id']) ||
            !isset($item['thuoc_tinh_id']) ||
            !isset($item['so_luong']) || !is_numeric($item['so_luong']) || $item['so_luong'] <= 0 ||
            !isset($item['don_gia']) || !is_numeric($item['don_gia']) || $item['don_gia'] < 0
        ) {
            throw new Exception("Thông tin chi tiết đơn hàng không hợp lệ. Yêu cầu san_pham_id, thuoc_tinh_id, so_luong, don_gia.");
        }

        $itemSanPhamId = $item['san_pham_id'];
        $itemThuocTinhId = $item['thuoc_tinh_id'];
        $itemSoLuong = (int)$item['so_luong'];
        $itemDonGia = (float)$item['don_gia'];
        $itemGiaGiam = isset($item['gia_giam']) ? (float)$item['gia_giam'] : 0;
        $itemTongGia = ($itemDonGia - $itemGiaGiam) * $itemSoLuong;

        mysqli_stmt_bind_param(
            $stmtOrderItem,
            "iiiiddd", // i: integer, d: double/decimal
            $donHangId,
            $itemSanPhamId,
            $itemThuocTinhId,
            $itemSoLuong,
            $itemDonGia,
            $itemGiaGiam,
            $itemTongGia
        );

        if (!mysqli_stmt_execute($stmtOrderItem)) {
            throw new Exception("Lỗi khi thêm chi tiết đơn hàng: " . mysqli_stmt_error($stmtOrderItem));
        }
    }
    mysqli_stmt_close($stmtOrderItem);

    // Nếu mọi thứ đều thành công, commit giao dịch
    mysqli_commit($conn);

    echo json_encode(array(
        "success" => true,
        "message" => "Tạo đơn hàng thành công!",
        "don_hang_id" => $donHangId,
        "ma_don_hang" => $maDonHang
    ));

} catch (Exception $e) {
    // Nếu có lỗi, hoàn tác giao dịch và trả về thông báo lỗi
    mysqli_rollback($conn);
    echo json_encode(array("message" => "Lỗi: " . $e->getMessage()));
} finally {
    // Đóng kết nối cơ sở dữ liệu
    mysqli_close($conn);
}
?>

