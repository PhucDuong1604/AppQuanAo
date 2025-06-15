<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/lichsu.php");
    $db = new Database();
    $conn = $db->connect();

    $ls = new LichSuTrangThaiDonHang($conn);
    $result = $ls->layDanhSachLichSuTrangThaiDonHang();
    if (mysqli_num_rows($result) > 0) {
        $dsls = [];
        $dsls["dslichsu"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $lichsu = array(
                "don_hang_id  " => $row["don_hang_id "],
                "trang_thai " => $row["trang_thai"],
                "thoi_gian_thay_doi " => $row["thoi_gian_thay_doi"],
                "ghi_chu " => $row["ghi_chu"],
                "nguoi_thay_doi " => $row["nguoi_thay_doi"],
            );
            array_push( $dsls["dslichsu"], $lichsu);
        }
        echo json_encode($dsls);
    }