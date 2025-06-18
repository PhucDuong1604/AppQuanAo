<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/db.php';

$database = new Database();
$conn = $database->connect();

$data = json_decode(file_get_contents("php://input"));

// Debugging: Log incoming data
error_log("Incoming order data: " . json_encode($data));

// 1. Kiểm tra dữ liệu bắt buộc
if (
    empty($data->nguoi_dung_id) ||
    empty($data->ten_nguoi_nhan) ||
    empty($data->sdt_nguoi_nhan) ||
    empty($data->dia_chi_giao_hang) ||
    empty($data->phuong_thuc_thanh_toan) ||
    empty($data->tong_tien) ||
    !isset($data->items) || !is_array($data->items) || count($data->items) === 0
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Dữ liệu đơn hàng không đầy đủ hoặc không hợp lệ."));
    mysqli_close($conn);
    exit();
}

$nguoi_dung_id = (int)$data->nguoi_dung_id;
$ten_nguoi_nhan = (string)$data->ten_nguoi_nhan;
$sdt_nguoi_nhan = (string)$data->sdt_nguoi_nhan;
$dia_chi_giao_hang = (string)$data->dia_chi_giao_hang;
$ghi_chu = isset($data->ghi_chu) ? (string)$data->ghi_chu : "";
$phuong_thuc_thanh_toan = (string)$data->phuong_thuc_thanh_toan;
$tong_tien = (float)$data->tong_tien;

// Trạng thái đơn hàng mặc định
$trang_thai_don_hang = "Chờ xác nhận"; // Hoặc "Đã đặt hàng"
if ($phuong_thuc_thanh_toan === "momo") {
    $trang_thai_thanh_toan = "Đã thanh toán"; // Giả định MoMo đã thanh toán thành công
} else {
    $trang_thai_thanh_toan = "Chưa thanh toán";
}

$conn->begin_transaction(); // Bắt đầu giao dịch

try {
    // 2. Chèn vào bảng don_hang
    $query_insert_don_hang = "INSERT INTO don_hang (
        nguoi_dung_id,
        ten_nguoi_nhan,
        sdt_nguoi_nhan,
        dia_chi_giao_hang,
        ghi_chu,
        phuong_thuc_thanh_toan,
        tong_tien,
        trang_thai_don_hang,
        trang_thai_thanh_toan
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt_insert_don_hang = $conn->prepare($query_insert_don_hang);
    if (!$stmt_insert_don_hang) {
        throw new Exception("Lỗi prepare insert don_hang: " . $conn->error);
    }
    // "isssssdss" -> i:nguoi_dung_id, s:ten, s:sdt, s:dia_chi, s:ghi_chu, s:phuong_thuc, d:tong_tien, s:trang_thai_don_hang, s:trang_thai_thanh_toan
    $stmt_insert_don_hang->bind_param("isssssdss",
        $nguoi_dung_id,
        $ten_nguoi_nhan,
        $sdt_nguoi_nhan,
        $dia_chi_giao_hang,
        $ghi_chu,
        $phuong_thuc_thanh_toan,
        $tong_tien,
        $trang_thai_don_hang,
        $trang_thai_thanh_toan
    );

    if (!$stmt_insert_don_hang->execute()) {
        throw new Exception("Không thể thêm đơn hàng mới. Lỗi: " . $stmt_insert_don_hang->error);
    }
    $don_hang_id = $conn->insert_id; // Lấy ID của đơn hàng vừa tạo
    $stmt_insert_don_hang->close();

    // 3. Chèn các mặt hàng vào bảng chi_tiet_don_hang
    $query_insert_chi_tiet = "INSERT INTO chi_tiet_don_hang (
        don_hang_id,
        san_pham_id,
        kich_thuoc,
        mau_sac,
        so_luong,
        gia_tai_thoi_diem_dat
    ) VALUES (?, ?, ?, ?, ?, ?)";

    $stmt_insert_chi_tiet = $conn->prepare($query_insert_chi_tiet);
    if (!$stmt_insert_chi_tiet) {
        throw new Exception("Lỗi prepare insert chi_tiet_don_hang: " . $conn->error);
    }

    foreach ($data->items as $item) {
        $item_san_pham_id = (string)$item->productId; // Giả định là VARCHAR
        $item_kich_thuoc = (string)$item->selectedSize;
        $item_mau_sac = (string)$item->selectedColor;
        $item_so_luong = (int)$item->quantity;
        $item_gia = (float)$item->pricePerItem;

        // "issidd" -> i:don_hang_id, s:san_pham_id, s:kich_thuoc, s:mau_sac, i:so_luong, d:gia_tai_thoi_diem_dat
        $stmt_insert_chi_tiet->bind_param("issidd",
            $don_hang_id,
            $item_san_pham_id,
            $item_kich_thuoc,
            $item_mau_sac,
            $item_so_luong,
            $item_gia
        );
        if (!$stmt_insert_chi_tiet->execute()) {
            throw new Exception("Không thể thêm chi tiết đơn hàng cho sản phẩm " . $item_san_pham_id . ". Lỗi: " . $stmt_insert_chi_tiet->error);
        }
    }
    $stmt_insert_chi_tiet->close();

    $conn->commit(); // Cam kết giao dịch nếu mọi thứ thành công
    http_response_code(201); // Created
    echo json_encode(array("success" => true, "message" => "Đơn hàng đã được đặt thành công!", "order_id" => $don_hang_id));

} catch (Exception $e) {
    $conn->rollback(); // Hoàn tác giao dịch nếu có lỗi
    http_response_code(500);
    error_log("Lỗi khi đặt đơn hàng: " . $e->getMessage());
    echo json_encode(array("success" => false, "message" => "Lỗi máy chủ nội bộ khi đặt hàng. Vui lòng thử lại sau."));
} finally {
    mysqli_close($conn);
}
?>