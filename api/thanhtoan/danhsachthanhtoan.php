<?php
    header("Content-Type: application/json");
    require_once("../../config/db.php");
    require_once("../../model/thanhtoan.php");
    $db = new Database();
    $conn = $db->connect();

    $th = new ThuongHieu($conn);
    $result = $th->layDanhSachThanhToan();
    if (mysqli_num_rows($result) > 0) {
        $dsth = [];
        $dsth["dsthuonghieu"] = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $thuonghieu = array(
                "ten" => $row["ten"],
                "mo_ta" => $row["mo_ta"],
                "logo" => $row["logo"],
                "website" => $row["website"],
                "trang_thai" => $row["trang_thai"],
            );
            array_push( $dsth["dsthuonghieu"], $thuonghieu);
        }
        echo json_encode($dsth);
    }