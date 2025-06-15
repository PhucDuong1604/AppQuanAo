<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/thanhtoan.php");
    $db = new Database();
    $conn = $db->connect();

    $tt = new ThanhToan($conn);
    $result = $tt->layDanhSachThanhToan();
    if (mysqli_num_rows($result) > 0) {
        $dstt = [];
        $dstt["dsthanhtoan"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $thanhtoan = array(
                "don_hang_id" => $row["don_hang_id"],
                "so_tien" => $row["so_tien"],
                "phuong_thuc" => $row["phuong_thuc"],
                "ma_giao_dich" => $row["ma_giao_dich"],
                "ngay_thanh_toan" => $row["ngay_thanh_toan"],
                "trang_thai" => $row["trang_thai"],
                "ghi_chu" => $row["ghi_chu"],
            );
            array_push( $dstt["dsthanhtoan"], $thanhtoan);
        }
        echo json_encode($dstt);
    }
    
