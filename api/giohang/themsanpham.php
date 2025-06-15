<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Bao gồm file kết nối cơ sở dữ liệu
include_once '../../config/database.php';

// Kết nối đến cơ sở dữ liệu
$database = new Database();
$db = $database->getConnection();

// Lấy dữ liệu POST từ Flutter
$data = json_decode(file_get_contents("php://input"));

// Kiểm tra xem dữ liệu cần thiết có được cung cấp đầy đủ không
if (
    empty($data->nguoi_dung_id) ||
    empty($data->san_pham_id) ||
    empty($data->so_luong) ||
    !isset($data->kich_thuoc) || // kich_thuoc và mau_sac có thể là null nhưng cần được set
    !isset($data->mau_sac)
) {
    http_response_code(400); // Bad Request
    echo json_encode(array("success" => false, "message" => "Dữ liệu không đầy đủ. Cần nguoi_dung_id, san_pham_id, so_luong, kich_thuoc, mau_sac."));
    exit();
}

$nguoi_dung_id = $data->nguoi_dung_id;
$san_pham_id = $data->san_pham_id;
$so_luong = $data->so_luong;
$kich_co = $data->kich_thuoc; // Giữ nguyên tên biến từ Flutter là kich_thuoc, nhưng dùng để truy vấn kich_co
$mau_sac = $data->mau_sac;

// Đảm bảo số lượng là số nguyên dương
if ($so_luong <= 0) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Số lượng phải là số nguyên dương."));
    exit();
}

try {
    // 1. Tìm hoặc tạo giỏ hàng (gio_hang) cho người dùng
    $query_gio_hang = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmt_gio_hang = $db->prepare($query_gio_hang);
    $stmt_gio_hang->execute([$nguoi_dung_id]);
    $gio_hang_data = $stmt_gio_hang->fetch(PDO::FETCH_ASSOC);

    $gio_hang_id;
    if ($gio_hang_data) {
        $gio_hang_id = $gio_hang_data['id'];
    } else {
        // Tạo giỏ hàng mới nếu chưa có
        $insert_gio_hang = "INSERT INTO gio_hang (nguoi_dung_id) VALUES (?)";
        $stmt_insert_gio_hang = $db->prepare($insert_gio_hang);
        if ($stmt_insert_gio_hang->execute([$nguoi_dung_id])) {
            $gio_hang_id = $db->lastInsertId();
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể tạo giỏ hàng mới cho người dùng."));
            exit();
        }
    }

    // 2. Tìm thuoc_tinh_id (ID thuộc tính sản phẩm) từ bảng chi_tiet_san_pham
    $query_thuoc_tinh = "SELECT id FROM chi_tiet_san_pham WHERE san_pham_id = ? AND kich_co <=> ? AND mau_sac <=> ?";
    $stmt_thuoc_tinh = $db->prepare($query_thuoc_tinh);
    $stmt_thuoc_tinh->execute([$san_pham_id, $kich_co, $mau_sac]);
    $thuoc_tinh_data = $stmt_thuoc_tinh->fetch(PDO::FETCH_ASSOC);

    if (!$thuoc_tinh_data) {
        http_response_code(404); // Not Found
        echo json_encode(array("success" => false, "message" => "Không tìm thấy thuộc tính sản phẩm (kích cỡ/màu sắc) phù hợp."));
        exit();
    }
    $thuoc_tinh_id = $thuoc_tinh_data['id'];

    // 3. Kiểm tra và cập nhật/thêm vào bảng chi_tiet_gio_hang
    $query_chi_tiet = "SELECT id, so_luong FROM chi_tiet_gio_hang WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
    $stmt_chi_tiet = $db->prepare($query_chi_tiet);
    $stmt_chi_tiet->execute([$gio_hang_id, $san_pham_id, $thuoc_tinh_id]);
    $existing_chi_tiet = $stmt_chi_tiet->fetch(PDO::FETCH_ASSOC);

    if ($existing_chi_tiet) {
        // Nếu mặt hàng đã tồn tại trong chi_tiet_gio_hang, cập nhật số lượng
        $new_so_luong = $existing_chi_tiet['so_luong'] + $so_luong;
        $update_query = "UPDATE chi_tiet_gio_hang SET so_luong = ?, ngay_them = CURRENT_TIMESTAMP WHERE id = ?";
        $update_stmt = $db->prepare($update_query);

        if ($update_stmt->execute([$new_so_luong, $existing_chi_tiet['id']])) {
            http_response_code(200); // OK
            echo json_encode(array("success" => true, "message" => "Đã cập nhật số lượng sản phẩm trong giỏ hàng."));
        } else {
            http_response_code(500); // Internal Server Error
            echo json_encode(array("success" => false, "message" => "Không thể cập nhật số lượng sản phẩm trong chi tiết giỏ hàng."));
        }
    } else {
        // Nếu mặt hàng chưa tồn tại, thêm mới vào chi_tiet_gio_hang
        $insert_query = "INSERT INTO chi_tiet_gio_hang (gio_hang_id, san_pham_id, thuoc_tinh_id, so_luong) VALUES (?, ?, ?, ?)";
        $insert_stmt = $db->prepare($insert_query);

        if ($insert_stmt->execute([$gio_hang_id, $san_pham_id, $thuoc_tinh_id, $so_luong])) {
            http_response_code(201); // Created
            echo json_encode(array("success" => true, "message" => "Sản phẩm đã được thêm vào giỏ hàng thành công."));
        } else {
            http_response_code(500); // Internal Server Error
            echo json_encode(array("success" => false, "message" => "Không thể thêm sản phẩm mới vào chi tiết giỏ hàng."));
        }
    }
} catch (PDOException $e) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("success" => false, "message" => "Lỗi cơ sở dữ liệu: " . $e->getMessage()));
}

$db = null; // Đóng kết nối
?>