<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../../config/db.php';

$database = new Database();
$conn = $database->connect();

$data = json_decode(file_get_contents("php://input"));

// Debugging: Log incoming data
error_log("Incoming delete selected items data: " . json_encode($data));

if (
    empty($data->nguoi_dung_id) ||
    !isset($data->items_to_delete) || !is_array($data->items_to_delete) || count($data->items_to_delete) === 0
) {
    http_response_code(400);
    echo json_encode(array("success" => false, "message" => "Dữ liệu không đầy đủ hoặc không hợp lệ."));
    mysqli_close($conn);
    exit();
}

$nguoi_dung_id = (string)$data->nguoi_dung_id; // userId có thể là INT hoặc VARCHAR tùy thuộc vào DB của bạn

$conn->begin_transaction(); // Bắt đầu giao dịch

try {
    $query = "DELETE FROM gio_hang WHERE nguoi_dung_id = ? AND san_pham_id = ? AND kich_thuoc = ? AND mau_sac = ?";
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception("Lỗi prepare statement: " . $conn->error);
    }

    $all_deleted_successfully = true;

    foreach ($data->items_to_delete as $item) {
        if (
            !isset($item->san_pham_id) ||
            !isset($item->kich_thuoc) ||
            !isset($item->mau_sac)
        ) {
            error_log("Skipping invalid item in batch delete: " . json_encode($item));
            continue; // Bỏ qua mục không hợp lệ
        }

        $san_pham_id = (string)$item->san_pham_id;
        $kich_thuoc = (string)$item->kich_thuoc;
        $mau_sac = (string)$item->mau_sac;

        $stmt->bind_param("ssss", $nguoi_dung_id, $san_pham_id, $kich_thuoc, $mau_sac);

        if (!$stmt->execute()) {
            error_log("Không thể xóa sản phẩm khỏi giỏ hàng. Lỗi: " . $stmt->error);
            $all_deleted_successfully = false;
            // Optionally, you might want to rollback here or collect specific errors
            // For now, we'll continue trying to delete other items but mark overall failure.
        }
    }

    $stmt->close();

    if ($all_deleted_successfully) {
        $conn->commit();
        http_response_code(200);
        echo json_encode(array("success" => true, "message" => "Đã xóa các sản phẩm đã chọn khỏi giỏ hàng thành công."));
    } else {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(array("success" => false, "message" => "Có lỗi xảy ra khi xóa một số sản phẩm đã chọn khỏi giỏ hàng."));
    }

} catch (Exception $e) {
    $conn->rollback();
    http_response_code(500);
    error_log("Lỗi khi xóa nhiều sản phẩm khỏi giỏ hàng: " . $e->getMessage());
    echo json_encode(array("success" => false, "message" => "Lỗi máy chủ nội bộ khi xóa các mục đã chọn."));
} finally {
    mysqli_close($conn);
}
?>