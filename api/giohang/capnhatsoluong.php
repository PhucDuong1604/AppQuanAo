<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST"); // Hoặc PUT
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/db.php'; // Đảm bảo file này dùng MySQLi và có hàm connect()

$database = new Database();
$conn = $database->connect(); // Lấy đối tượng mysqli connection

// Kiểm tra lỗi kết nối ngay lập tức
if (!$conn) {
    http_response_code(500);
    echo json_encode(array("success" => false, "message" => "Không thể kết nối cơ sở dữ liệu."));
    exit();
}

$data = json_decode(file_get_contents("php://input"));

// Kiểm tra dữ liệu cần thiết
// Các trường này cần được gửi từ Flutter: nguoi_dung_id, san_pham_id, kich_thuoc, mau_sac, new_so_luong
if (
    empty($data->nguoi_dung_id) || // ID người dùng để tìm/tạo giỏ hàng
    empty($data->san_pham_id) ||
    !isset($data->kich_thuoc) || // Có thể là null, nhưng cần được gửi
    !isset($data->mau_sac) ||    // Có thể là null, nhưng cần được gửi
    !isset($data->new_so_luong)  // Số lượng mới (bao gồm 0 cho việc xóa)
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Dữ liệu không đầy đủ. Cần nguoi_dung_id, san_pham_id, kich_thuoc, mau_sac, new_so_luong."));
    mysqli_close($conn);
    exit();
}

$nguoi_dung_id = $data->nguoi_dung_id;
$san_pham_id = $data->san_pham_id;
$kich_co = $data->kich_thuoc;
$mau_sac = $data->mau_sac;
$new_so_luong = $data->new_so_luong;

// Đảm bảo số lượng mới không âm (số lượng 0 sẽ được hiểu là xóa)
if ($new_so_luong < 0) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Số lượng mới không hợp lệ. Phải là số nguyên không âm."));
    mysqli_close($conn);
    exit();
}

try {
    // 1. Tìm hoặc tạo giỏ hàng (gio_hang) cho người dùng
    $query_gio_hang = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmt_gio_hang = $conn->prepare($query_gio_hang);
    if ($stmt_gio_hang === false) {
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => "Lỗi prepare statement khi tìm giỏ hàng: " . $conn->error));
        mysqli_close($conn);
        exit();
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
        // Nếu không có giỏ hàng, tạo mới.
        // Điều này chỉ nên xảy ra nếu người dùng chưa có giỏ hàng,
        // nếu không, giỏ hàng đã được tạo khi thêm sản phẩm đầu tiên.
        $insert_gio_hang = "INSERT INTO gio_hang (nguoi_dung_id) VALUES (?)";
        $stmt_insert_gio_hang = $conn->prepare($insert_gio_hang);
        if ($stmt_insert_gio_hang === false) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Lỗi prepare statement khi tạo giỏ hàng: " . $conn->error));
            mysqli_close($conn);
            exit();
        }
        $stmt_insert_gio_hang->bind_param("i", $nguoi_dung_id);
        if ($stmt_insert_gio_hang->execute()) {
            $gio_hang_id = $conn->insert_id;
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể tạo giỏ hàng mới cho người dùng."));
            mysqli_close($conn);
            exit();
        }
        $stmt_insert_gio_hang->close();
    }

    // 2. Tìm thuoc_tinh_id (ID thuộc tính sản phẩm) từ bảng chi_tiet_san_pham
    // Sử dụng <=> cho null-safe comparison (yêu cầu MySQL 8.0+).
    // Nếu MySQL cũ hơn, cần logic kiểm tra NULL phức tạp hơn.
    $query_thuoc_tinh = "SELECT id FROM chi_tiet_san_pham WHERE san_pham_id = ? AND (kich_co <=> ?) AND (mau_sac <=> ?)";
    $stmt_thuoc_tinh = $conn->prepare($query_thuoc_tinh);
    if ($stmt_thuoc_tinh === false) {
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => "Lỗi prepare statement khi tìm thuộc tính sản phẩm: " . $conn->error));
        mysqli_close($conn);
        exit();
    }
    $stmt_thuoc_tinh->bind_param("iss", $san_pham_id, $kich_co, $mau_sac); // 'i' for int, 's' for string
    $stmt_thuoc_tinh->execute();
    $result_thuoc_tinh = $stmt_thuoc_tinh->get_result();
    $thuoc_tinh_data = $result_thuoc_tinh->fetch_assoc();
    $stmt_thuoc_tinh->close();

    if (!$thuoc_tinh_data) {
        http_response_code(404);
        echo json_encode(array("success" => false, "message" => "Không tìm thấy thuộc tính sản phẩm (kích cỡ/màu sắc) phù hợp."));
        mysqli_close($conn);
        exit();
    }
    $thuoc_tinh_id = $thuoc_tinh_data['id'];

    // 3. Xử lý cập nhật hoặc xóa trong bảng chi_tiet_gio_hang
    if ($new_so_luong == 0) {
        // Xóa sản phẩm khỏi giỏ hàng
        $delete_query = "DELETE FROM chi_tiet_gio_hang WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
        $stmt_delete = $conn->prepare($delete_query);
        if ($stmt_delete === false) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Lỗi prepare statement khi xóa sản phẩm: " . $conn->error));
            mysqli_close($conn);
            exit();
        }
        $stmt_delete->bind_param("iii", $gio_hang_id, $san_pham_id, $thuoc_tinh_id);
        if ($stmt_delete->execute()) {
            http_response_code(200);
            echo json_encode(array("success" => true, "message" => "Đã xóa sản phẩm khỏi giỏ hàng."));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể xóa sản phẩm khỏi giỏ hàng: " . $stmt_delete->error));
        }
        $stmt_delete->close();
    } else {
        // Cập nhật số lượng sản phẩm
        $update_query = "UPDATE chi_tiet_gio_hang SET so_luong = ?, ngay_them = CURRENT_TIMESTAMP WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
        $stmt_update = $conn->prepare($update_query);
        if ($stmt_update === false) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Lỗi prepare statement khi cập nhật số lượng: " . $conn->error));
            mysqli_close($conn);
            exit();
        }
        $stmt_update->bind_param("iiii", $new_so_luong, $gio_hang_id, $san_pham_id, $thuoc_tinh_id);
        if ($stmt_update->execute()) {
            // Kiểm tra xem có dòng nào được cập nhật không
            if ($stmt_update->affected_rows > 0) {
                http_response_code(200);
                echo json_encode(array("success" => true, "message" => "Đã cập nhật số lượng sản phẩm trong giỏ hàng."));
            } else {
                // Nếu affected_rows là 0, có thể do sản phẩm chưa có trong giỏ hàng.
                // Trong trường hợp này, bạn có thể chọn thêm mới sản phẩm vào giỏ hàng
                // (giống như logic trong themsanpham.php), hoặc thông báo lỗi.
                // Để nhất quán với themsanpham.php, chúng ta nên thêm mới nếu không tìm thấy.
                // Tuy nhiên, API này là "cập nhật", nên thông báo lỗi "không tìm thấy để cập nhật" là hợp lý hơn.
                // Tùy thuộc vào yêu cầu nghiệp vụ của bạn.
                http_response_code(404); // Not Found for update
                echo json_encode(array("success" => false, "message" => "Sản phẩm không tồn tại trong giỏ hàng để cập nhật."));
            }
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Không thể cập nhật số lượng sản phẩm trong giỏ hàng: " . $stmt_update->error));
        }
        $stmt_update->close();
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(array("success" => false, "message" => "Lỗi cơ sở dữ liệu: " . $e->getMessage()));
} finally {
    mysqli_close($conn); // Đảm bảo đóng kết nối MySQLi
}
?>