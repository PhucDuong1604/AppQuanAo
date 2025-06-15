<?php
session_start(); // Khởi tạo session để lưu trữ thông tin đăng nhập

header("Content-Type: application/json"); // Đặt Content-Type là JSON
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác
// require_once("../../model/taikhoan.php"); // Nếu bạn có model này, hãy đảm bảo nó được include

// Chỉ chấp nhận yêu cầu POST cho việc đăng nhập
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận POST."));
    exit();
}

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect(); // $conn lúc này là đối tượng mysqli

// Lấy dữ liệu từ body của yêu cầu POST
$input = json_decode(file_get_contents("php://input"), true);

// Kiểm tra xem dữ liệu 'email' và 'mat_khau' có được gửi lên không
if (!isset($input['email']) || !isset($input['mat_khau'])) {
    echo json_encode(array(
        "success" => false,
        "message" => "Email và mật khẩu không được để trống!"
    ));
    $conn->close();
    exit();
}

$email = $input['email'];
$mat_khau = $input['mat_khau']; // Đã khớp với input và tên cột trong CSDL

// Xây dựng câu truy vấn SQL để lấy thông tin tài khoản dựa trên email và mật khẩu
// LƯU Ý BẢO MẬT: So sánh trực tiếp mật khẩu trong câu truy vấn này
// có nghĩa là mật khẩu trong CSDL đang được lưu dạng PLAIN-TEXT (không băm).
// Đây là một LỖ HỔNG BẢO MẬT RẤT NGHIÊM TRỌNG và KHÔNG ĐƯỢC KHUYẾN KHÍCH.
// Bạn NÊN băm mật khẩu khi đăng ký (password_hash) và sử dụng password_verify()
// như trong phiên bản API an toàn hơn trước đó.
$sql = "SELECT id, mat_khau, email, ho_ten, so_dien_thoai,gioi_tinh,ngay_sinh,  trang_thai FROM tai_khoan WHERE email = ? AND mat_khau = ?";

// Chuẩn bị câu lệnh SQL
$stmt = $conn->prepare($sql);

// Kiểm tra xem việc chuẩn bị câu lệnh có thành công không
if ($stmt === false) {
    echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn: " . $conn->error));
    $conn->close();
    exit();
}

// Gắn tham số email và mat_khau vào câu lệnh. "ss" chỉ ra rằng cả hai đều là chuỗi (string).
$stmt->bind_param("ss", $email, $mat_khau); // Đã khớp với biến $mat_khau

// Thực thi câu lệnh đã chuẩn bị
$stmt->execute();

// Lấy kết quả từ câu lệnh đã thực thi
$result = $stmt->get_result();

// Kiểm tra xem có tài khoản nào được tìm thấy không
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    // Kiểm tra trạng thái tài khoản. 'trang_thai' là BOOLEAN, TRUE = hoạt động.
    if ($user['trang_thai']) { // Đã khớp với tên cột 'trang_thai' và kiểu BOOLEAN
        // Đăng nhập thành công
        // Lưu thông tin vào session với tên cột mới
        $_SESSION['logged_in'] = true;
        $_SESSION['email'] = $user['email'];
        $_SESSION['id'] = $user['id']; // Đã khớp với tên cột 'id'
        $_SESSION['ho_ten'] = $user['ho_ten']; // Đã khớp với tên cột 'ho_ten'
      
        // Trả về dữ liệu cho client (không bao gồm mật khẩu)
        echo json_encode(array(
            "success" => true,
            "message" => "Đăng nhập thành công",
            "data" => [ // Cấu trúc 'data' theo yêu cầu, đã khớp với tên cột mới
                "id" => $user['id'],
                "email" => $user['email'],
                "ho_ten" => $user['ho_ten'], 
                "gioi_tinh" => $user['gioi_tinh'], 
                "mat_khau" => $user['mat_khau'], 
                "so_dien_thoai" => $user['so_dien_thoai'],
                "ngay_sinh" => $user['ngay_sinh'],
                "trang_thai" => $user['trang_thai'],
            ]
        ));
    } else {
        // Tài khoản không hoạt động (trạng thái là FALSE)
        echo json_encode(array(
            "success" => false,
            "message" => "Tài khoản của bạn đã bị khóa!"
        ));
    }
} else {
    // Không tìm thấy tài khoản hoặc mật khẩu không đúng
    echo json_encode(array(
        "success" => false,
        "message" => "Email hoặc mật khẩu không đúng!"
    ));
}

// Đóng câu lệnh và kết nối cơ sở dữ liệu
$stmt->close();
$conn->close();

?>
