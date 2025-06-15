<?php
class LichSuTrangThaiDonHang
{
    private $conn;

    public $don_hang_id  ;
    public $trang_thai  ;
    public $thoi_gian_thay_doi ;
    public $ghi_chu ;
    public $nguoi_thay_doi ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachLichSuTrangThaiDonHang()
    {
        $sql = "SELECT * FROM lich_su_trang_thai_don_hang";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
}