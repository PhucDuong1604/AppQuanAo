<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/db.php'; // File db.php dùng mysqli

$database = new Database();
$conn = $database->connect(); // GỌI PHƯƠNG THỨC 'connect()' VÀ NHẬN VỀ ĐỐI TƯỢNG mysqli

// Lấy dữ liệu POST
$data = json_decode(file_get_contents("php://input"));

if (
    empty($data->nguoi_dung_id) ||
    empty($data->san_pham_id) ||
    empty($data->so_luong) ||
    !isset($data->kich_thuoc) ||
    !isset($data->mau_sac)
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Dữ liệu không đầy đủ."));
    mysqli_close($conn); // Đóng kết nối mysqli
    exit();
}

$nguoi_dung_id = $data->nguoi_dung_id;
$san_pham_id = $data->san_pham_id;
$so_luong = $data->so_luong;
$kich_co = $data->kich_thuoc;
$mau_sac = $data->mau_sac;

if ($so_luong <= 0) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Số lượng phải là số nguyên dương."));
    mysqli_close($conn);
    exit();
}

try {
    // 1. Tìm hoặc tạo giỏ hàng (gio_hang) cho người dùng
    $query_gio_hang = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmt_gio_hang = $conn->prepare($query_gio_hang); // MySQLi prepare
    $stmt_gio_hang->bind_param("i", $nguoi_dung_id); // Bind parameter cho mysqli
    $stmt_gio_hang->execute();
    $result_gio_hang = $stmt_gio_hang->get_result();
    $gio_hang_data = $result_gio_hang->fetch_assoc(); // mysqli fetch_assoc()

    $gio_hang_id;
    if ($gio_hang_data) {
        $gio_hang_id = $gio_hang_data['id'];
    } else {
        $insert_gio_hang = "INSERT INTO gio_hang (nguoi_dung_id) VALUES (?)";
        $stmt_insert_gio_hang = $conn->prepare($insert_gio_hang);
        $stmt_insert_gio_hang->bind_param("i", $nguoi_dung_id);
        if ($stmt_insert_gio_hang->execute()) {
            $gio_hang_id = $conn->insert_id; // mysqli insert_id
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể tạo giỏ hàng mới cho người dùng."));
            mysqli_close($conn);
            exit();
        }
        $stmt_insert_gio_hang->close();
    }
    $stmt_gio_hang->close();

    // 2. Tìm thuoc_tinh_id (ID thuộc tính sản phẩm)
    $query_thuoc_tinh = "SELECT id FROM chi_tiet_san_pham WHERE san_pham_id = ? AND (kich_co <=> ?) AND (mau_sac <=> ?)";
    $stmt_thuoc_tinh = $conn->prepare($query_thuoc_tinh);
    // Sử dụng "s" cho string, "i" cho integer. Cần kiểm tra kiểu dữ liệu thực tế của kich_co và mau_sac
    $stmt_thuoc_tinh->bind_param("iss", $san_pham_id, $kich_co, $mau_sac); // Assuming int, string, string
    $stmt_thuoc_tinh->execute();
    $result_thuoc_tinh = $stmt_thuoc_tinh->get_result();
    $thuoc_tinh_data = $result_thuoc_tinh->fetch_assoc();

    if (!$thuoc_tinh_data) {
        http_response_code(404);
        echo json_encode(array("success" => false, "message" => "Không tìm thấy thuộc tính sản phẩm (kích cỡ/màu sắc) phù hợp."));
        mysqli_close($conn);
        exit();
    }
    $thuoc_tinh_id = $thuoc_tinh_data['id'];
    $stmt_thuoc_tinh->close();

    // 3. Kiểm tra và cập nhật/thêm vào bảng chi_tiet_gio_hang
    $query_chi_tiet = "SELECT id, so_luong FROM chi_tiet_gio_hang WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
    $stmt_chi_tiet = $conn->prepare($query_chi_tiet);
    $stmt_chi_tiet->bind_param("iii", $gio_hang_id, $san_pham_id, $thuoc_tinh_id);
    $stmt_chi_tiet->execute();
    $result_chi_tiet = $stmt_chi_tiet->get_result();
    $existing_chi_tiet = $result_chi_tiet->fetch_assoc();
    $stmt_chi_tiet->close();

    if ($existing_chi_tiet) {
        $new_so_luong = $existing_chi_tiet['so_luong'] + $so_luong;
        $update_query = "UPDATE chi_tiet_gio_hang SET so_luong = ?, ngay_them = CURRENT_TIMESTAMP WHERE id = ?";
        $update_stmt = $conn->prepare($update_query);
        $update_stmt->bind_param("ii", $new_so_luong, $existing_chi_tiet['id']);
        if ($update_stmt->execute()) {
            http_response_code(200);
            echo json_encode(array("success" => true, "message" => "Đã cập nhật số lượng sản phẩm trong giỏ hàng."));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể cập nhật số lượng sản phẩm trong chi tiết giỏ hàng."));
        }
        $update_stmt->close();
    } else {
        $insert_query = "INSERT INTO chi_tiet_gio_hang (gio_hang_id, san_pham_id, thuoc_tinh_id, so_luong) VALUES (?, ?, ?, ?)";
        $insert_stmt = $conn->prepare($insert_query);
        $insert_stmt->bind_param("iiii", $gio_hang_id, $san_pham_id, $thuoc_tinh_id, $so_luong);
        if ($insert_stmt->execute()) {
            http_response_code(201);
            echo json_encode(array("success" => true, "message" => "Sản phẩm đã được thêm vào giỏ hàng thành công."));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể thêm sản phẩm mới vào chi tiết giỏ hàng."));
        }
        $insert_stmt->close();
    }
} catch (Exception $e) { // Catch Exception cho mysqli
    http_response_code(500);
    echo json_encode(array("success" => false, "message" => "Lỗi cơ sở dữ liệu: " . $e->getMessage()));
}

mysqli_close($conn); // Đóng kết nối mysqli
?>