<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/chitietdonhang.php");
    $db = new Database();
    $conn = $db->connect();

    $ctsp = new ChiTietDonHang($conn);
    $result = $ctsp->layDanhSachChiTietDonHang();
    if (mysqli_num_rows($result) > 0) {
        $dsctdh = [];
        $dsctdh["dschitietdonhang"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $chitietdonhang = array(
                "don_hang_id " => $row["don_hang_id"],
                "san_pham_id " => $row["san_pham_id"],
                "thuoc_tinh_id " => $row["thuoc_tinh_id"],
                "so_luong " => $row["so_luong"],
                "don_gia " => $row["don_gia"],
                "gia_giam " => $row["gia_giam"],
                "tong_gia " => $row["tong_gia"],
            );
            array_push( $dsctdh["dschitietdonhang"], $chitietdonhang);
        }
        echo json_encode($dsctdh);
    }
