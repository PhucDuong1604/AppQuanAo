<?php
// Tắt hiển thị lỗi PHP trên trình duyệt/phản hồi API
// Điều này giúp ngăn chặn các thông báo lỗi làm hỏng định dạng JSON
ini_set('display_errors', 'Off');
error_reporting(E_ALL); // Vẫn ghi nhận tất cả lỗi vào log (nếu cấu hình)

header("Content-Type: application/json; charset=UTF-8"); // Đặt Content-Type là JSON, kèm charset
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác

// API này chủ yếu xử lý yêu cầu GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận GET."), JSON_UNESCAPED_UNICODE);
    exit();
}

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Kiểm tra kết nối CSDL
if (!$conn) {
    echo json_encode(array("message" => "Lỗi kết nối cơ sở dữ liệu."), JSON_UNESCAPED_UNICODE);
    exit();
}

// Lấy tham số 'nguoi_dung_id' từ URL. Đây là trường bắt buộc.
// Sử dụng filter_input để lấy dữ liệu GET an toàn hơn
$nguoiDungId = filter_input(INPUT_GET, 'nguoi_dung_id', FILTER_VALIDATE_INT);

// Kiểm tra xem 'nguoi_dung_id' có được cung cấp và là số nguyên hợp lệ không
if ($nguoiDungId === null || $nguoiDungId === false) {
    echo json_encode(array("message" => "Vui lòng cung cấp 'nguoi_dung_id' hợp lệ để lấy danh sách đơn hàng."), JSON_UNESCAPED_UNICODE);
    mysqli_close($conn);
    exit();
}

// Xây dựng câu truy vấn SQL để lấy tất cả thông tin từ bảng don_hang
// Chỉ lấy các đơn hàng của người dùng cụ thể
$sql = "SELECT
            id,
            ma_don_hang,
            nguoi_dung_id,
            ngay_dat,
            tong_tien,
            phi_van_chuyen,
            giam_gia,
            thanh_tien,
            dia_chi_giao_hang,
            dia_chi_thanh_toan,
            phuong_thuc_thanh_toan,
            trang_thai_thanh_toan,
            trang_thai_don_hang,
            ma_theo_doi,
            ghi_chu
        FROM
            don_hang
        WHERE
            nguoi_dung_id = ?
        ORDER BY
            ngay_dat DESC; -- Sắp xếp theo ngày đặt mới nhất
";

// Chuẩn bị câu lệnh SQL để thực thi (Prepared Statement)
$stmt = mysqli_prepare($conn, $sql);

// Kiểm tra xem việc chuẩn bị câu lệnh có thành công không
if ($stmt === false) {
    echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn: " . mysqli_error($conn)), JSON_UNESCAPED_UNICODE);
    mysqli_close($conn);
    exit();
}

// Gắn tham số 'nguoi_dung_id' vào câu lệnh. "i" chỉ ra rằng đây là một số nguyên (integer).
mysqli_stmt_bind_param($stmt, "i", $nguoiDungId);

// Thực thi câu lệnh đã chuẩn bị
mysqli_stmt_execute($stmt);

// Lấy kết quả từ câu lệnh đã thực thi
$result = mysqli_stmt_get_result($stmt);

// Kiểm tra xem việc thực thi truy vấn có thành công không
if ($result === false) {
    echo json_encode(array("message" => "Lỗi khi lấy danh sách đơn hàng: " . mysqli_stmt_error($stmt)), JSON_UNESCAPED_UNICODE);
} elseif (mysqli_num_rows($result) > 0) {
    // Nếu có đơn hàng, tạo một mảng để chứa dữ liệu
    $orders = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $orders[] = $row; // Thêm từng dòng kết quả vào mảng
    }
    // Trả về dữ liệu dưới dạng JSON
    echo json_encode($orders, JSON_UNESCAPED_UNICODE);
} else {
    // Nếu không tìm thấy đơn hàng nào cho người dùng này
    echo json_encode(array("message" => "Không tìm thấy đơn hàng nào cho người dùng có ID: " . $nguoiDungId), JSON_UNESCAPED_UNICODE);
}

// Đóng câu lệnh và kết nối cơ sở dữ liệu
mysqli_stmt_close($stmt);
mysqli_close($conn);

// Đảm bảo không có ký tự nào khác được in ra sau khi JSON đã được gửi
exit();
?>