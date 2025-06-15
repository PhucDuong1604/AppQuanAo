<?php
header("Content-Type: application/json");

require_once("../../config/db.php");
require_once("../../model/taikhoan.php"); // Đảm bảo đường dẫn này đúng

$db = new Database();
$conn = $db->connect();

// === ĐIỀU CHỈNH CHỖ NÀY ===
// Rất có thể class được định nghĩa là 'TaiKhoan' (chữ T và K viết hoa)
// Hãy kiểm tra lại file '../../model/taikhoan.php' của bạn để xác nhận tên class chính xác.
$taiKhoan = new TaiKhoan($conn); // Đã sửa từ 'tai_khoan' thành 'TaiKhoan' (nếu đó là tên class của bạn)
// Hoặc nếu tên class thực sự là 'tai_khoan' (chữ thường), thì lỗi này có thể do file không được include đúng.
// Hãy kiểm tra đường dẫn file '../../model/taikhoan.php' là tuyệt đối đúng.

$data = json_decode(file_get_contents("php://input"));

// Kiểm tra xem dữ liệu có tồn tại không trước khi truy cập các thuộc tính
if ($data === null) {
    echo json_encode(["success" => false, "message" => "Dữ liệu gửi lên không hợp lệ."]);
    exit();
}

// Gán dữ liệu vào các thuộc tính của đối tượng tài khoản
// Đảm bảo tên thuộc tính (email, mat_khau,...) khớp với tên trong class TaiKhoan
$taiKhoan->mat_khau = $data->mat_khau ?? null; // Sử dụng null coalescing operator cho các trường tùy chọn
$taiKhoan->email = $data->email ?? null;
$taiKhoan->ho_ten = $data->ho_ten ?? null;
$taiKhoan->so_dien_thoai = $data->so_dien_thoai ?? null;
$taiKhoan->ngay_sinh = $data->ngay_sinh ?? null;
$taiKhoan->gioi_tinh = $data->gioi_tinh ?? null;
$taiKhoan->trang_thai = $data->trang_thai ?? true; // Nếu trang_thai là boolean, nên mặc định là true hoặc lấy từ dữ liệu

// Gọi phương thức thêm tài khoản
$resultTaiKhoan = $taiKhoan->themTaiKhoan(); 

// Kiểm tra kết quả
// Phương thức themTaiKhoan() của bạn nên trả về true/false hoặc một mảng lỗi
if ($resultTaiKhoan === true) {
    echo json_encode(["success" => true, "message" => "Thêm tài khoản thành công!"]);
} else {
    // Nếu themTaiKhoan() trả về chuỗi lỗi, hãy hiển thị nó
    echo json_encode(["success" => false, "message" => "Lỗi: " . $resultTaiKhoan]);
}

$conn->close();

?>
