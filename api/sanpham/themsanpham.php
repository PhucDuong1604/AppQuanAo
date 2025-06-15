<?php
header("Content-Type: application/json");
require_once("../../config/db.php");
require_once("../../model/chitietsanpham.php");

$db = new Database();
$conn = $db->connect();

$data = json_decode(file_get_contents("php://input"));

if (!$data) {
    echo json_encode(["error" => "Dữ liệu đầu vào không hợp lệ"]);
    exit;
}

$ctsp = new ChiTietSanPham($conn);
$ctsp->san_pham_id    = $data->san_pham_id ?? null;
$ctsp->kich_co        = $data->kich_co ?? null;
$ctsp->mau_sac        = $data->mau_sac ?? null;
$ctsp->chat_lieu      = $data->chat_lieu ?? null;
$ctsp->trong_luong    = $data->trong_luong ?? 0;
$ctsp->so_luong_ton   = $data->so_luong_ton ?? 0;

$result = $ctsp->themChiTietSanPham();

if ($result === true) {
    echo json_encode(["message" => "Thêm chi tiết sản phẩm thành công!"]);
} else {
    echo json_encode(["error" => "Lỗi: " . $result]);
}
