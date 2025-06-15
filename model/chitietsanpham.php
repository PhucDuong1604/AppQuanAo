<?php
class ChiTietSanPham
{
    private $conn;
 
    public $san_pham_id;
    public $kich_co;
    public $mau_sac;
    public $chat_lieu;
    public $trong_luong;
    public $so_luong_ton;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }

    public function layDanhSachChiTietSanPham()
    {
        $sql = "SELECT * FROM chi_tiet_san_pham";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }


    public function xoaChiTietSanPham()
    {
        $sql = "DELETE FROM chi_tiet_san_pham WHERE san_pham_id ='" . $this->san_pham_id . "'";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }

    public function suaChiTietSanPham()
    {
 
        $sqlCheck = "SELECT COUNT(*) FROM chi_tiet_san_pham WHERE san_pham_id = ?";
        $stmtCheck = $this->conn->prepare($sqlCheck);
        $stmtCheck->bind_param("s", $this->san_pham_id); 
        $stmtCheck->execute();
        $resultCheck = $stmtCheck->get_result();
        $row = $resultCheck->fetch_array();

        if ($row[0] == 0) {
            return "Lỗi: san_pham_id không tồn tại!";
        }

        $sql = "UPDATE chi_tiet_san_pham SET 
                    kich_co = ?, 
                    mau_sac = ?, 
                    chat_lieu = ?, 
                    trong_luong = ?, 
                    so_luong_ton = ?
                    
                WHERE san_pham_id = ?";

        $stmt = $this->conn->prepare($sql);

        $stmt->bind_param("sssssss", $this->kich_co, $this->mau_sac, $this->chat_lieu, $this->trong_luong, $this->so_luong_ton, $this->san_pham_id);

        if ($stmt->execute()) {
            return true;
        } else {
            return "Lỗi: " . $stmt->error;
        }
    }
}
?>
