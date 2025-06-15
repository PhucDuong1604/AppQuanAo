<?php
header("Content-Type: application/json"); // Đặt Content-Type là JSON
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác

// Chỉ chấp nhận yêu cầu POST cho việc tạo thanh toán mới
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận POST."));
    exit();
}

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Lấy dữ liệu từ body của yêu cầu POST
$input = json_decode(file_get_contents("php://input"), true);

// Kiểm tra các trường bắt buộc
if (
    !isset($input['don_hang_id']) ||
    !isset($input['so_tien']) ||
    !isset($input['phuong_thuc'])
) {
    echo json_encode(array("message" => "Vui lòng cung cấp đủ thông tin: don_hang_id, so_tien, phuong_thuc."));
    mysqli_close($conn);
    exit();
}

$donHangId = $input['don_hang_id'];
$soTien = $input['so_tien'];
$phuongThuc = $input['phuong_thuc'];
$maGiaoDich = isset($input['ma_giao_dich']) ? $input['ma_giao_dich'] : null;
$trangThai = isset($input['trang_thai']) ? $input['trang_thai'] : 'cho_xu_ly'; // Mặc định là 'cho_xu_ly'
$ghiChu = isset($input['ghi_chu']) ? $input['ghi_chu'] : null;

// Xây dựng câu truy vấn SQL để chèn dữ liệu vào bảng thanh_toan
$sql = "INSERT INTO thanh_toan (don_hang_id, so_tien, phuong_thuc, ma_giao_dich, trang_thai, ghi_chu) VALUES (?, ?, ?, ?, ?, ?)";

// Chuẩn bị câu lệnh SQL
$stmt = mysqli_prepare($conn, $sql);

// Kiểm tra xem việc chuẩn bị câu lệnh có thành công không
if ($stmt === false) {
    echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn: " . mysqli_error($conn)));
    mysqli_close($conn);
    exit();
}

// Gắn tham số vào câu lệnh
// "ids" nghĩa là: integer, decimal (float), string, string, string, string
// Đối với DECIMAL, mysqli_stmt_bind_param cần "d" (double) hoặc "f" (float) hoặc "s" (string) nếu muốn giữ độ chính xác.
// Tuy nhiên, "d" là phổ biến nhất cho DECIMAL.
mysqli_stmt_bind_param($stmt, "idssss", $donHangId, $soTien, $phuongThuc, $maGiaoDich, $trangThai, $ghiChu);

// Thực thi câu lệnh đã chuẩn bị
$executeResult = mysqli_stmt_execute($stmt);

// Kiểm tra kết quả thực thi
if ($executeResult) {
    // Lấy ID của bản ghi mới được tạo
    $newPaymentId = mysqli_insert_id($conn);
    echo json_encode(array(
        "success" => true,
        "message" => "Tạo thanh toán thành công!",
        "payment_id" => $newPaymentId
    ));
} else {
    // Nếu có lỗi khi thực thi
    echo json_encode(array("message" => "Lỗi khi tạo thanh toán: " . mysqli_stmt_error($stmt)));
}

// Đóng câu lệnh và kết nối cơ sở dữ liệu
mysqli_stmt_close($stmt);
mysqli_close($conn);

?>
