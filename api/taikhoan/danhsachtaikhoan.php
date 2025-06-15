<?php
header("Content-Type: application/json"); // Đặt Content-Type là JSON
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác

// API này chủ yếu xử lý yêu cầu GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận GET."));
    exit();
}

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Lấy tham số 'tai_khoan_id' từ URL (nếu có).
// Tham số này là tùy chọn, nếu không có sẽ lấy tất cả tài khoản.
$taiKhoanId = isset($_GET['tai_khoan_id']) ? $_GET['tai_khoan_id'] : null;

// Xây dựng câu truy vấn SQL để lấy thông tin tài khoản
// KHÔNG BAO GỒM trường 'mat_khau' để bảo mật
$sql = "SELECT id ,mat_khau, email, ho_ten, so_dien_thoai, gioi_tinh, ngay_sinh, trang_thai FROM tai_khoan";

// Nếu 'tai_khoan_id' được cung cấp, thêm điều kiện WHERE vào truy vấn
if ($taiKhoanId !== null) {
    $sql .= " WHERE id = ?"; // Sử dụng placeholder '?' cho prepared statement
}

// Chuẩn bị câu lệnh SQL để thực thi (Prepared Statement)
$stmt = mysqli_prepare($conn, $sql);

// Kiểm tra xem việc chuẩn bị câu lệnh có thành công không
if ($stmt === false) {
    echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn: " . mysqli_error($conn)));
    mysqli_close($conn);
    exit(); // Dừng thực thi nếu có lỗi
}

// Nếu 'tai_khoan_id' được cung cấp, gắn tham số vào câu lệnh
if ($taiKhoanId !== null) {
    // "i" chỉ ra rằng $taiKhoanId là một số nguyên (integer)
    mysqli_stmt_bind_param($stmt, "i", $taiKhoanId);
}

// Thực thi câu lệnh đã chuẩn bị
mysqli_stmt_execute($stmt);

// Lấy kết quả từ câu lệnh đã thực thi
$result = mysqli_stmt_get_result($stmt);

// Kiểm tra xem việc thực thi truy vấn có thành công không
if ($result === false) {
    echo json_encode(array("message" => "Lỗi khi lấy danh sách tài khoản: " . mysqli_stmt_error($stmt)));
} elseif (mysqli_num_rows($result) > 0) {
    // Nếu có bản ghi tài khoản, tạo một mảng để chứa dữ liệu
    $accounts = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $accounts[] = $row; // Thêm từng dòng kết quả vào mảng
    }
    // Trả về dữ liệu dưới dạng JSON
    echo json_encode($accounts);
} else {
    // Nếu không tìm thấy bản ghi tài khoản nào
    echo json_encode(array("message" => "Không tìm thấy tài khoản nào."));
}

// Đóng câu lệnh và kết nối cơ sở dữ liệu
mysqli_stmt_close($stmt);
mysqli_close($conn);

?>
