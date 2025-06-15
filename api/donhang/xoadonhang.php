<?php
header("Content-Type: application/json");
require_once("../../config/db.php");
require_once("../../model/nhanvien.php");
$db = new Database();
$conn = $db->connect();

$dh = new DonHang($conn);
$data = json_decode(file_get_contents("php://input"));
$dh->ma_don_hang = $data->ma_don_hang;
$dh->ma_don_hang = $data->ma_don_hang;
$result = $dh->xoaDonHang();
if ($result == true) {
    echo json_encode(array("message", "Xóa đơn hàng thành công"));
} else {
    echo json_encode(array("message", "Xóa đơn hàng thất bại"));
}
