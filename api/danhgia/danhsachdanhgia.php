<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/danhgia.php");
    $db = new Database();
    $conn = $db->connect();

    $dg = new DanhGiaSanPham($conn);
    $result = $dg->layDanhSachDanhGia();
    if (mysqli_num_rows($result) > 0) {
        $dsdg = [];
        $dsdg["dsdanhgia"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $danhgia = array(
                "san_pham_id " => $row["san_pham_id"],
                "nguoi_dung_id " => $row["nguoi_dung_id"],
                "diem " => $row["diem"],
                "binh_luan " => $row["binh_luan"],
                "ngay_danh_gia " => $row["ngay_danh_gia"],
                "duoc_duyet " => $row["duoc_duyet"],
            );
            array_push( $dsdg["dsdanhgia"], $danhgia);
        }
        echo json_encode($dsdg);
    }
