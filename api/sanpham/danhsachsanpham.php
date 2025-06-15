<?php
header("Content-Type: application/json");
header('Access-Control-Allow-Origin: *'); // Cho phép tất cả các domain truy cập (cho mục đích phát triển)
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once("../../config/db.php"); // Đảm bảo đường dẫn này chính xác

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Lấy tham số 'san_pham_id' từ URL. Nếu không có, gán null.
$productIdParam = isset($_GET['san_pham_id']) ? intval($_GET['san_pham_id']) : null;
// Lấy tham số 'category' từ URL (tên danh mục)
$categoryParam = isset($_GET['category']) ? $_GET['category'] : null;

$products = []; // Mảng để lưu trữ kết quả

// --- TRUY VẤN CHÍNH ĐỂ LẤY THÔNG TIN SẢN PHẨM ---
// Sử dụng LEFT JOIN để đảm bảo sản phẩm vẫn được hiển thị ngay cả khi không có đánh giá
$sql = "
    SELECT
        sp.id AS id_sanpham,
        sp.ma_san_pham,
        sp.ten AS ten_sanpham,
        sp.mo_ta,
        sp.gia,
        sp.gia_giam AS gia_cu, -- Đổi tên cột gia_giam thành gia_cu cho Flutter
        dm.ten AS category,    -- Lấy tên danh mục từ bảng danh_muc
        (
            SELECT duong_dan_anh
            FROM hinh_anh_san_pham
            WHERE san_pham_id = sp.id AND anh_chinh = TRUE
            ORDER BY thu_tu ASC
            LIMIT 1
        ) AS hinh_anh, -- Đổi tên cột thành hinh_anh cho Flutter
        AVG(dgp.diem) AS danh_gia, -- Tính điểm trung bình (rating)
        COUNT(dgp.id) AS so_luong_danh_gia -- Đếm số lượng đánh giá (reviewCount)
    FROM
        san_pham sp
    JOIN
        danh_muc dm ON sp.danh_muc_id = dm.id -- Nối với bảng danh_muc để lấy tên danh mục
    LEFT JOIN
        danh_gia_san_pham dgp ON sp.id = dgp.san_pham_id -- Nối với bảng đánh giá để tính rating/reviewCount
    WHERE
        sp.trang_thai = TRUE
";

$params = [];
$types = "";

if ($productIdParam) {
    $sql .= " AND sp.id = ?";
    $params[] = $productIdParam;
    $types .= "i";
}

if ($categoryParam) {
    // Đảm bảo lọc theo tên danh mục
    $sql .= " AND dm.ten = ?";
    $params[] = $categoryParam;
    $types .= "s";
}

$sql .= "
    GROUP BY
        sp.id, sp.ma_san_pham, sp.ten, sp.mo_ta, sp.gia, sp.gia_giam, dm.ten
    ORDER BY
        sp.ngay_tao DESC; -- Sắp xếp theo ngày tạo (mới nhất)
";

$stmt = mysqli_prepare($conn, $sql);

if ($stmt === false) {
    echo json_encode(array("error" => "Lỗi chuẩn bị truy vấn sản phẩm: " . mysqli_error($conn)));
    mysqli_close($conn);
    exit();
}

if (!empty($params)) {
    // Sử dụng call_user_func_array để bind_param với số lượng tham số động
    mysqli_stmt_bind_param($stmt, $types, ...$params);
}

mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if ($result === false) {
    echo json_encode(array("error" => "Lỗi thực thi truy vấn sản phẩm: " . mysqli_stmt_error($stmt)));
    mysqli_stmt_close($stmt);
    mysqli_close($conn);
    exit();
}

// Lặp qua kết quả để lấy thông tin sản phẩm và biến thể (kích cỡ, màu sắc)
while ($row = mysqli_fetch_assoc($result)) {
    $currentProductId = $row['id_sanpham'];

    // --- TRUY VẤN KÍCH CỠ VÀ MÀU SẮC CHO TỪNG SẢN PHẨM ---
    $sizes = [];
    $colors = [];
    // Lấy DISTINCT kích cỡ và màu sắc từ chi_tiet_san_pham
    $details_sql = "SELECT DISTINCT kich_co, mau_sac FROM chi_tiet_san_pham WHERE san_pham_id = ?";
    $details_stmt = mysqli_prepare($conn, $details_sql);
    if ($details_stmt) {
        mysqli_stmt_bind_param($details_stmt, "i", $currentProductId);
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
    }

    $products[] = [
        "id_sanpham" => (string)$row['id_sanpham'], // Đảm bảo là string cho Flutter
        "ten_sanpham" => $row['ten_sanpham'],
        "hinh_anh" => $row['hinh_anh'] ?? "https://via.placeholder.com/150", // Fallback ảnh
        "gia" => $row['gia'], // Ép kiểu thành float
        "gia_cu" => $row['gia_cu'] ? $row['gia_cu'] : null, // Ép kiểu và kiểm tra null
        "mo_ta" => $row['mo_ta'],
        "category" => $row['category'] ?? "Chưa phân loại", // Default category
        "danh_gia" => (float)($row['danh_gia'] ?? 0.0), // Ép kiểu float, default 0.0
        "so_luong_danh_gia" => (int)($row['so_luong_danh_gia'] ?? 0), // Ép kiểu int, default 0
        "kich_thuoc" => implode(',', array_unique($sizes)), // Nối mảng sizes thành chuỗi, loại bỏ trùng lặp
        "mau_sac" => implode(',', array_unique($colors)), // Nối mảng colors thành chuỗi, loại bỏ trùng lặp
    ];
}

mysqli_close($conn); // Đóng kết nối sau khi đã hoàn tất các truy vấn

if (!empty($products)) {
    // Nếu chỉ truy vấn một sản phẩm, trả về đối tượng đơn thay vì mảng một phần tử
    if ($productIdParam && count($products) == 1) {
        echo json_encode($products[0]);
    } else {
        echo json_encode($products);
    }
} else {
    echo json_encode(array("message" => "Không tìm thấy sản phẩm nào."));
}

?>