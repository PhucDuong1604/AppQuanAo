<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/hinhanh.php");
    $db = new Database();
    $conn = $db->connect();

    $h = new HinhAnh($conn);
    $result = $h->layDanhSachHinhAnh();
    if (mysqli_num_rows($result) > 0) {
        $dsh = [];
        $dsh["dshinhanh"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $hinhanh = array(
                "san_pham_id " => $row["san_pham_id"],
                "duong_dan_anh " => $row["duong_dan_anh"],
                "anh_chinh " => $row["anh_chinh"],
                "thu_tu " => $row["thu_tu"],
            );
            array_push( $dsh["dshinhanh"], $hinhanh);
        }
        echo json_encode($dsh);
    }