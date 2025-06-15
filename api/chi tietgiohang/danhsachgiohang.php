<?php
header("Content-Type: application/json");
require_once("../../config/db.php");
require_once("../../model/chitietgiohang.php");

$db = new Database();
$conn = $db->connect();

$data = json_decode(file_get_contents("php://input"));
if (!$data) {
    echo json_encode(["error" => "Dữ liệu không hợp lệ hoặc không tồn tại"]);
    exit;
}

$ctgh = new ChiTietGioHang($conn);

$ctgh->gio_hang_id    = $data->gio_hang_id ?? null;
$ctgh->san_pham_id    = $data->san_pham_id ?? null;
$ctgh->thuoc_tinh_id  = $data->thuoc_tinh_id ?? null;
$ctgh->so_luong       = $data->so_luong ?? 1;

if (!$ctgh->gio_hang_id || !$ctgh->san_pham_id || !$ctgh->thuoc_tinh_id) {
    echo json_encode(["error" => "Thiếu dữ liệu bắt buộc"]);
    exit;
}

$result = $ctgh->themChiTietGioHang();

if ($result === true) {
    echo json_encode(["message" => "Thêm chi tiết giỏ hàng thành công"]);
} else {
    echo json_encode(["error" => "Lỗi: " . $result]);
}
