<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/khuyenmai.php");
    $db = new Database();
    $conn = $db->connect();

    $gg = new KhuyenMai($conn);
    $result = $gg->layDanhSachKhuyenMai();
    if (mysqli_num_rows($result) > 0) {
        $dsgg = [];
        $dsgg["dskhuyenmai"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $giamgia = array(
                "ma" => $row["ma"],
                "ten" => $row["ten"],
                "mo_ta" => $row["mo_ta"],
                "loai_giam_gia" => $row["loai_giam_gia"],
                "gia_tri_giam" => $row["gia_tri_giam"],
                "gia_tri_toi_thieu" => $row["gia_tri_toi_thieu"],
                "ngay_bat_dau" => $row["ngay_bat_dau"],
                "ngay_ket_thuc" => $row["ngay_ket_thuc"],
                "so_luong_toi_da" => $row["so_luong_toi_da"],
                "so_luong_da_dung" => $row["so_luong_da_dung"],
                "trang_thai" => $row["trang_thai"],
                "ngay_tao" => $row["ngay_tao"],
                "san_pham" => $row["san_pham"],
            );
            array_push( $dsgg["dsgiamgia"] , $giamgia);
        }
        echo json_encode($dsgg);
    }
