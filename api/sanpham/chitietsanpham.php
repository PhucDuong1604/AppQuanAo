<?php
// Bật hiển thị tất cả các lỗi PHP để dễ dàng debug trong quá trình phát triển.
// QUAN TRỌNG: Hãy tắt hoặc xóa những dòng này khi triển khai lên môi trường thực tế (production).
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Thiết lập tiêu đề HTTP để phản hồi là JSON và cho phép CORS
header("Content-Type: application/json; charset=UTF-8");
header('Access-Control-Allow-Origin: *'); // Cho phép tất cả các domain truy cập (cho mục đích phát triển)
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Chỉ cho phép GET, POST, OPTIONS
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Xử lý các yêu cầu OPTIONS (preflight requests) từ trình duyệt
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Đường dẫn tương đối đến file kết nối cơ sở dữ liệu.
// Đảm bảo file 'db.php' nằm ở thư mục 'config' hai cấp trên so với thư mục hiện tại.
require_once("../../config/db.php");

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database(); // Giả định bạn có một class Database với phương thức connect()
$conn = $db->connect(); // $conn lúc này là đối tượng mysqli

// Kiểm tra lỗi kết nối cơ sở dữ liệu
if ($conn->connect_error) {
    http_response_code(500); // Internal Server Error
    echo json_encode([
        "success" => false,
        "message" => "Lỗi kết nối cơ sở dữ liệu: " . $conn->connect_error
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Chỉ chấp nhận yêu cầu GET cho API chi tiết sản phẩm
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode([
        "success" => false,
        "message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận GET."
    ], JSON_UNESCAPED_UNICODE);
    $conn->close();
    exit();
}

// Lấy product ID từ tham số truy vấn 'id'
// Ví dụ: http://10.0.2.2/apiAppQuanAo/api/sanpham/chitietsanpham.php?id=123
$productId = isset($_GET['id']) ? $_GET['id'] : null;

// Đảm bảo $productId tồn tại và là một số nguyên hợp lệ
if ($productId === null || !is_numeric($productId)) {
    http_response_code(400); // Bad Request
    echo json_encode([
        "success" => false,
        "message" => "Product ID is missing or invalid."
    ], JSON_UNESCAPED_UNICODE);
    $conn->close();
    exit();
}

$productId = intval($productId); // Chuyển đổi thành số nguyên để đảm bảo an toàn

// --- TRUY VẤN CHÍNH ĐỂ LẤY THÔNG TIN CHI TIẾT SẢN PHẨM ---
// Đã hoán đổi cột gia và gia_giam trong kết quả truy vấn
$sql = "SELECT
            sp.id AS id_sanpham,
            sp.ma_san_pham,
            sp.ten AS ten_sanpham,
            sp.mo_ta,
            sp.gia AS gia_cu_from_db,      -- Lấy cột 'gia' trong DB, gán tạm là gia_cu_from_db
            sp.gia_giam AS gia_hien_tai_from_db, -- Lấy cột 'gia_giam' trong DB, gán tạm là gia_hien_tai_from_db
            dm.ten AS category,
            (
                SELECT duong_dan_anh
                FROM hinh_anh_san_pham
                WHERE san_pham_id = sp.id AND anh_chinh = TRUE
                ORDER BY thu_tu ASC
                LIMIT 1
            ) AS hinh_anh,
            AVG(dgp.diem) AS danh_gia,
            COUNT(dgp.id) AS so_luong_danh_gia
        FROM
            san_pham sp
        LEFT JOIN
            danh_muc dm ON sp.danh_muc_id = dm.id
        LEFT JOIN
            danh_gia_san_pham dgp ON sp.id = dgp.san_pham_id
        WHERE
            sp.id = ? AND sp.trang_thai = TRUE
        GROUP BY
            sp.id, sp.ma_san_pham, sp.ten, sp.mo_ta, sp.gia, sp.gia_giam, dm.ten
        LIMIT 1";

$stmt = $conn->prepare($sql);

if ($stmt === false) {
    http_response_code(500); // Internal Server Error
    echo json_encode([
        "success" => false,
        "message" => "Lỗi chuẩn bị truy vấn sản phẩm chính: " . $conn->error
    ], JSON_UNESCAPED_UNICODE);
    $conn->close();
    exit();
}

$stmt->bind_param("i", $productId);
$stmt->execute();
$result = $stmt->get_result();

$product = null;

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();

    // --- TRUY VẤN KÍCH CỠ VÀ MÀU SẮC CHO SẢN PHẨM HIỆN TẠI ---
    $sizes = [];
    $colors = [];
    $details_sql = "SELECT DISTINCT kich_co, mau_sac FROM chi_tiet_san_pham WHERE san_pham_id = ?";
    $details_stmt = mysqli_prepare($conn, $details_sql);

    if ($details_stmt) {
        mysqli_stmt_bind_param($details_stmt, "i", $productId);
        mysqli_stmt_execute($details_stmt);
        $details_result = mysqli_stmt_get_result($details_stmt);
        while ($detail_row = mysqli_fetch_assoc($details_result)) {
            if (!empty($detail_row['kich_co'])) {
                $sizes[] = $detail_row['kich_co'];
            }
            if (!empty($detail_row['mau_sac'])) {
                $colors[] = $detail_row['mau_sac'];
            }
        }
        mysqli_stmt_close($details_stmt);
    } else {
        error_log("Lỗi chuẩn bị truy vấn chi tiết kích cỡ/màu sắc cho sản phẩm ID " . $productId . ": " . mysqli_error($conn));
    }

    $product = [
    "id_sanpham" => (string)$row["id_sanpham"],
    "ma_san_pham" => $row["ma_san_pham"],
    "ten_sanpham" => $row["ten_sanpham"],
    "hinh_anh" => $row["hinh_anh"] ?? "https://via.placeholder.com/150",
    // Ép kiểu sang float cho 'gia' để đảm bảo là số thập phân
    "gia" => (float)($row["gia_hien_tai_from_db"] ?? $row["gia_cu_from_db"]), // Giá hiện tại lấy từ gia_hien_tai_from_db (nếu có), nếu không thì lấy từ gia_cu_from_db
    // Ép kiểu sang float cho 'gia_cu'
    "gia_cu" => (float)($row["gia_cu_from_db"] ?? 0.0), // Giá cũ lấy từ gia_cu_from_db, mặc định là 0.0 nếu null
    "mo_ta" => $row["mo_ta"],
    "category" => $row["category"] ?? "Chưa phân loại",
    "danh_gia" => (float)($row["danh_gia"] ?? 0.0),
    "so_luong_danh_gia" => (int)($row["so_luong_danh_gia"] ?? 0),
    "kich_thuoc" => implode(',', array_unique($sizes)),
    "mau_sac" => implode(',', array_unique($colors))
];

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "message" => "Product details fetched successfully.",
        "data" => $product
    ], JSON_UNESCAPED_UNICODE);

} else {
    http_response_code(404);
    echo json_encode([
        "success" => false,
        "message" => "Product not found."
    ], JSON_UNESCAPED_UNICODE);
}

$stmt->close();
$conn->close();
?>