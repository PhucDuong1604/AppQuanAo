<?php
// Tắt hiển thị lỗi PHP trên trình duyệt/phản hồi API
ini_set('display_errors', 'Off');
error_reporting(E_ALL); // Đảm bảo tất cả lỗi được ghi vào log

header("Content-Type: application/json; charset=UTF-8");
require_once("../../config/db.php"); // Đảm bảo đường dẫn chính xác

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận GET."), JSON_UNESCAPED_UNICODE);
    exit();
}

$db = new Database();
$conn = $db->connect();

if (!$conn) {
    error_log("ERROR: Lỗi kết nối cơ sở dữ liệu."); // Log lỗi kết nối
    echo json_encode(array("message" => "Lỗi kết nối cơ sở dữ liệu."), JSON_UNESCAPED_UNICODE);
    exit();
}

$nguoiDungId = filter_input(INPUT_GET, 'nguoi_dung_id', FILTER_VALIDATE_INT);

if ($nguoiDungId === null || $nguoiDungId === false) {
    error_log("ERROR: nguoi_dung_id không hợp lệ hoặc thiếu: " . ($nguoiDungId === null ? 'NULL' : 'FALSE'));
    echo json_encode(array("message" => "Vui lòng cung cấp 'nguoi_dung_id' hợp lệ để lấy danh sách đơn hàng."), JSON_UNESCAPED_UNICODE);
    mysqli_close($conn);
    exit();
}

// --- Bước 1: Lấy thông tin đơn hàng ---
$sqlOrders = "SELECT
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
                ngay_dat DESC;
";

$stmtOrders = mysqli_prepare($conn, $sqlOrders);

if ($stmtOrders === false) {
    error_log("ERROR: Lỗi chuẩn bị truy vấn đơn hàng (sqlOrders): " . mysqli_error($conn));
    echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn đơn hàng."), JSON_UNESCAPED_UNICODE);
    mysqli_close($conn);
    exit();
}

mysqli_stmt_bind_param($stmtOrders, "i", $nguoiDungId);
mysqli_stmt_execute($stmtOrders);
$resultOrders = mysqli_stmt_get_result($stmtOrders);

if ($resultOrders === false) {
    error_log("ERROR: Lỗi khi lấy danh sách đơn hàng (resultOrders): " . mysqli_stmt_error($stmtOrders));
    echo json_encode(array("message" => "Lỗi khi lấy danh sách đơn hàng: " . mysqli_stmt_error($stmtOrders)), JSON_UNESCAPED_UNICODE);
} elseif (mysqli_num_rows($resultOrders) > 0) {
    $orders = [];
    $orderIds = [];

    while ($row = mysqli_fetch_assoc($resultOrders)) {
        // Ép kiểu các trường số từ chuỗi sang số thực/số nguyên
        $row['id'] = (int)$row['id'];
        $row['nguoi_dung_id'] = (int)$row['nguoi_dung_id'];
        $row['tong_tien'] = (float)$row['tong_tien'];
        $row['phi_van_chuyen'] = (float)$row['phi_van_chuyen'];
        $row['giam_gia'] = (float)$row['giam_gia'];
        $row['thanh_tien'] = (float)$row['thanh_tien'];

        $orderIds[] = $row['id'];
        $orders[$row['id']] = $row;
        $orders[$row['id']]['chi_tiet_san_pham'] = []; // Khởi tạo mảng trống cho chi tiết sản phẩm
    }
    mysqli_stmt_close($stmtOrders);

    error_log("DEBUG: Các ID đơn hàng được lấy: " . implode(', ', $orderIds));

    // --- Bước 2: Lấy chi tiết sản phẩm và thuộc tính của chúng cho TẤT CẢ các đơn hàng đã lấy ---
    if (!empty($orderIds)) {
        $placeholders = implode(',', array_fill(0, count($orderIds), '?'));
        
        $sqlOrderItems = "SELECT
                            ctdh.don_hang_id,
                            ctdh.san_pham_id,
                            sp.ten,
                            ctdh.thuoc_tinh_id,
                            ctsp.mau_sac,
                            ctsp.kich_co,
                            ctdh.so_luong,
                            ctdh.don_gia,
                            ctdh.gia_giam,
                            ctdh.tong_gia,
                            (SELECT h.duong_dan_anh FROM hinh_anh_san_pham h WHERE h.san_pham_id = sp.id AND h.anh_chinh = TRUE LIMIT 1) AS hinh_anh
                        FROM
                            chi_tiet_don_hang ctdh
                        JOIN
                            san_pham sp ON ctdh.san_pham_id = sp.id
                        JOIN
                            chi_tiet_san_pham ctsp ON ctdh.thuoc_tinh_id = ctsp.id
                        WHERE
                            ctdh.don_hang_id IN ($placeholders)
                        ORDER BY
                            ctdh.don_hang_id, sp.ten;";

        error_log("DEBUG: SQL Order Items Query: " . $sqlOrderItems);
        
        $stmtOrderItems = mysqli_prepare($conn, $sqlOrderItems);
        
        if ($stmtOrderItems === false) {
            error_log("ERROR: Lỗi chuẩn bị truy vấn chi tiết đơn hàng (ORDER ITEMS - sqlOrderItems): " . mysqli_error($conn));
        } else {
            // Gắn tham số (số nguyên) cho từng ID đơn hàng
            $types = str_repeat('i', count($orderIds));
            error_log("DEBUG: Bind Types for Order Items: " . $types);
            error_log("DEBUG: Bind Values for Order Items: " . json_encode($orderIds));

            // Sử dụng call_user_func_array để bind_param với số lượng tham số động
            call_user_func_array('mysqli_stmt_bind_param', array_merge([$stmtOrderItems, $types], $orderIds));
            
            mysqli_stmt_execute($stmtOrderItems);
            
            // Kiểm tra lỗi sau khi execute
            if (mysqli_stmt_error($stmtOrderItems)) {
                 error_log("ERROR: Lỗi thực thi truy vấn chi tiết đơn hàng (ORDER ITEMS - execute): " . mysqli_stmt_error($stmtOrderItems));
            }

            $resultOrderItems = mysqli_stmt_get_result($stmtOrderItems);

            if ($resultOrderItems === false) {
                error_log("ERROR: Lỗi khi lấy kết quả chi tiết đơn hàng (ORDER ITEMS - get_result): " . mysqli_stmt_error($stmtOrderItems));
            } else {
                if (mysqli_num_rows($resultOrderItems) == 0) {
                     error_log("DEBUG: Không tìm thấy chi tiết đơn hàng nào cho các ID đã cho trong truy vấn chi tiết sản phẩm.");
                }
                while ($itemRow = mysqli_fetch_assoc($resultOrderItems)) {
                    // Ép kiểu các trường số của chi tiết sản phẩm
                    $itemRow['don_hang_id'] = (int)$itemRow['don_hang_id'];
                    $itemRow['san_pham_id'] = (int)$itemRow['san_pham_id'];
                    $itemRow['thuoc_tinh_id'] = (int)$itemRow['thuoc_tinh_id'];
                    $itemRow['so_luong'] = (int)$itemRow['so_luong'];
                    $itemRow['don_gia'] = (float)$itemRow['don_gia'];
                    $itemRow['gia_giam'] = (float)$itemRow['gia_giam'];
                    $itemRow['tong_gia'] = (float)$itemRow['tong_gia'];

                    error_log("DEBUG: Found item for order " . $itemRow['don_hang_id'] . ": " . json_encode($itemRow));

                    // Thêm chi tiết sản phẩm vào đơn hàng tương ứng
                    if (isset($orders[$itemRow['don_hang_id']])) {
                        $orders[$itemRow['don_hang_id']]['chi_tiet_san_pham'][] = $itemRow;
                    } else {
                        error_log("WARNING: Chi tiết sản phẩm được tìm thấy cho don_hang_id=" . $itemRow['don_hang_id'] . " nhưng đơn hàng đó không có trong danh sách gốc. Có thể có vấn đề với truy vấn đơn hàng ban đầu hoặc ID.");
                    }
                }
            }
            mysqli_stmt_close($stmtOrderItems);
        }
    } else {
        error_log("DEBUG: Không có ID đơn hàng nào được lấy ở Bước 1, không thực hiện truy vấn chi tiết sản phẩm.");
    }

    // Chuyển đổi mảng liên kết (keyed by order_id) thành mảng tuần tự để gửi JSON
    echo json_encode(array_values($orders), JSON_UNESCAPED_UNICODE);
} else {
    // Nếu không tìm thấy đơn hàng nào cho người dùng này
    error_log("DEBUG: Không tìm thấy đơn hàng nào cho người dùng có ID: " . $nguoiDungId);
    echo json_encode(array("message" => "Không tìm thấy đơn hàng nào cho người dùng có ID: " . $nguoiDungId), JSON_UNESCAPED_UNICODE);
}

mysqli_close($conn);
exit();
?>