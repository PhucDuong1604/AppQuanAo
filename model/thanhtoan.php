<?php
class ThanhToan
{
    private $conn;

    public $don_hang_id;
    public $so_tien ;
    public $phuong_thuc ;
    public $ma_giao_dich ;
    public $ngay_thanh_toan ;
    public $trang_thai ;
    public $ghi_chu ;
    
    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachThanhToan()
    {
        $sql = "SELECT * FROM thanh_toan";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
    
}
