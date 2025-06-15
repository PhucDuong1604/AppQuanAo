<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/danhmuc.php");
    $db = new Database();
    $conn = $db->connect();

    $dm = new DanhMuc($conn);
    $result = $dm->layDanhSachDanhMuc();
    if (mysqli_num_rows($result) > 0) {
        $dsdm = [];
        $dsdm["dsdanhmuc"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $danhmuc = array(
                "ten " => $row["ten"],
                "mo_ta " => $row["mo_ta"],
                "danh_muc_cha " => $row["danh_muc_cha"],
                "trang_thai " => $row["trang_thai"],
            );
            array_push( $dsdm["dsdanhmuc"], $danhmuc);
        }
        echo json_encode($dsdm);
    }

