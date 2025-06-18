<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/db.php'; // File db.php dùng mysqli

$database = new Database();
$conn = $database->connect();

// Lấy dữ liệu POST
$data = json_decode(file_get_contents("php://input"));

// Debugging: Ghi lại dữ liệu nhận được
error_log("Incoming JSON data: " . json_encode($data));

if (
    !isset($data->nguoi_dung_id) || // Dùng isset để chấp nhận 0 hoặc chuỗi rỗng nếu có thể
    !isset($data->san_pham_id) ||
    !isset($data->so_luong) ||
    !isset($data->kich_thuoc) || // Phải có key ngay cả khi giá trị là null hoặc rỗng
    !isset($data->mau_sac)
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Dữ liệu không đầy đủ (missing keys)."));
    mysqli_close($conn);
    exit();
}

// Chuyển đổi dữ liệu sang kiểu phù hợp và chuẩn hóa giá trị rỗng/null
$nguoi_dung_id = (int)$data->nguoi_dung_id; // Đảm bảo là int
$san_pham_id = (string)$data->san_pham_id; // Đảm bảo là string
$so_luong = (int)$data->so_luong; // Đảm bảo là int
$kich_co = isset($data->kich_thuoc) ? (string)$data->kich_thuoc : ""; // Nếu không có hoặc null, đặt là rỗng
$mau_sac = isset($data->mau_sac) ? (string)$data->mau_sac : ""; // Nếu không có hoặc null, đặt là rỗng

// Debugging: Ghi lại các biến sau khi xử lý
error_log("Processed Data: UserID=$nguoi_dung_id, SanPhamID=$san_pham_id, SoLuong=$so_luong, KichCo='$kich_co', MauSac='$mau_sac'");

if ($so_luong <= 0) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Số lượng phải là số nguyên dương."));
    mysqli_close($conn);
    exit();
}

try {
    // 1. Tìm hoặc tạo giỏ hàng (gio_hang) cho người dùng
    $query_gio_hang = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmt_gio_hang = $conn->prepare($query_gio_hang);
    if (!$stmt_gio_hang) {
        throw new Exception("Lỗi prepare query gio_hang: " . $conn->error);
    }
    $stmt_gio_hang->bind_param("i", $nguoi_dung_id);
    $stmt_gio_hang->execute();
    $result_gio_hang = $stmt_gio_hang->get_result();
    $gio_hang_data = $result_gio_hang->fetch_assoc();
    $stmt_gio_hang->close();

    $gio_hang_id;
    if ($gio_hang_data) {
        $gio_hang_id = $gio_hang_data['id'];
    } else {
        $insert_gio_hang = "INSERT INTO gio_hang (nguoi_dung_id) VALUES (?)";
        $stmt_insert_gio_hang = $conn->prepare($insert_gio_hang);
        if (!$stmt_insert_gio_hang) {
            throw new Exception("Lỗi prepare insert gio_hang: " . $conn->error);
        }
        $stmt_insert_gio_hang->bind_param("i", $nguoi_dung_id);
        if ($stmt_insert_gio_hang->execute()) {
            $gio_hang_id = $conn->insert_id;
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể tạo giỏ hàng mới cho người dùng. Lỗi: " . $stmt_insert_gio_hang->error));
            mysqli_close($conn);
            exit();
        }
        $stmt_insert_gio_hang->close();
    }

    // 2. Tìm thuoc_tinh_id (ID thuộc tính sản phẩm)
    // GIẢ ĐỊNH san_pham_id LÀ VARCHAR (string) trong DB
    $query_thuoc_tinh = "SELECT id FROM chi_tiet_san_pham WHERE san_pham_id = ? AND (kich_co <=> ?) AND (mau_sac <=> ?)";
    $stmt_thuoc_tinh = $conn->prepare($query_thuoc_tinh);
    if (!$stmt_thuoc_tinh) {
        throw new Exception("Lỗi prepare query thuoc_tinh: " . $conn->error);
    }
    // Đã thay đổi "iss" thành "sss"
    $stmt_thuoc_tinh->bind_param("sss", $san_pham_id, $kich_co, $mau_sac);
    $stmt_thuoc_tinh->execute();
    $result_thuoc_tinh = $stmt_thuoc_tinh->get_result();
    $thuoc_tinh_data = $result_thuoc_tinh->fetch_assoc();
    $stmt_thuoc_tinh->close();

    if (!$thuoc_tinh_data) {
        http_response_code(404);
        echo json_encode(array("success" => false, "message" => "Không tìm thấy thuộc tính sản phẩm (kích cỡ/màu sắc) phù hợp với SPID: '$san_pham_id', KC: '$kich_co', MS: '$mau_sac'.")); // Thông báo chi tiết hơn
        mysqli_close($conn);
        exit();
    }
    $thuoc_tinh_id = $thuoc_tinh_data['id'];

    // 3. Kiểm tra và cập nhật/thêm vào bảng chi_tiet_gio_hang
    // GIẢ ĐỊNH san_pham_id LÀ VARCHAR (string) trong DB
    $query_chi_tiet = "SELECT id, so_luong FROM chi_tiet_gio_hang WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
    $stmt_chi_tiet = $conn->prepare($query_chi_tiet);
    if (!$stmt_chi_tiet) {
        throw new Exception("Lỗi prepare query chi_tiet_gio_hang: " . $conn->error);
    }
    // Đã thay đổi "iii" thành "isi" nếu gio_hang_id là int, san_pham_id là string, thuoc_tinh_id là int
    $stmt_chi_tiet->bind_param("isi", $gio_hang_id, $san_pham_id, $thuoc_tinh_id);
    $stmt_chi_tiet->execute();
    $result_chi_tiet = $stmt_chi_tiet->get_result();
    $existing_chi_tiet = $result_chi_tiet->fetch_assoc();
    $stmt_chi_tiet->close();

    if ($existing_chi_tiet) {
        $new_so_luong = $existing_chi_tiet['so_luong'] + $so_luong;
        $update_query = "UPDATE chi_tiet_gio_hang SET so_luong = ?, ngay_them = CURRENT_TIMESTAMP WHERE id = ?";
        $update_stmt = $conn->prepare($update_query);
        if (!$update_stmt) {
            throw new Exception("Lỗi prepare update chi_tiet_gio_hang: " . $conn->error);
        }
        $update_stmt->bind_param("ii", $new_so_luong, $existing_chi_tiet['id']);
        if ($update_stmt->execute()) {
            http_response_code(200);
            echo json_encode(array("success" => true, "message" => "Đã cập nhật số lượng sản phẩm trong giỏ hàng."));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể cập nhật số lượng sản phẩm trong chi tiết giỏ hàng. Lỗi: " . $update_stmt->error));
        }
        $update_stmt->close();
    } else {
        $insert_query = "INSERT INTO chi_tiet_gio_hang (gio_hang_id, san_pham_id, thuoc_tinh_id, so_luong) VALUES (?, ?, ?, ?)";
        $insert_stmt = $conn->prepare($insert_query);
        if (!$insert_stmt) {
            throw new Exception("Lỗi prepare insert chi_tiet_gio_hang: " . $conn->error);
        }
        // Đã thay đổi "iiii" thành "isii" nếu gio_hang_id là int, san_pham_id là string, thuoc_tinh_id là int, so_luong là int
        $insert_stmt->bind_param("isii", $gio_hang_id, $san_pham_id, $thuoc_tinh_id, $so_luong);
        if ($insert_stmt->execute()) {
            http_response_code(201);
            echo json_encode(array("success" => true, "message" => "Sản phẩm đã được thêm vào giỏ hàng thành công."));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể thêm sản phẩm mới vào chi tiết giỏ hàng. Lỗi: " . $insert_stmt->error));
        }
        $insert_stmt->close();
    }
} catch (Exception $e) {
    http_response_code(500);
    error_log("Lỗi trong themsanpham.php: " . $e->getMessage()); // Ghi lỗi vào log
    echo json_encode(array("success" => false, "message" => "Lỗi máy chủ nội bộ. Vui lòng thử lại sau.")); // Thông báo lỗi chung cho người dùng
} finally {
    mysqli_close($conn);
}
?>