<?php
class KhuyenMai
{
    private $conn;

    public $ma ;
    public $ten  ;
    public $mo_ta ;
    public $loai_giam_gia ;
    public $gia_tri_giam ;
    public $gia_tri_toi_thieu ;
    public $ngay_bat_dau ;
    public $ngay_ket_thuc ;
    public $so_luong_toi_da ;
    public $so_luong_da_dung ;
    public $trang_thai ;
    public $ngay_tao ;
    public $san_pham ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachKhuyenMai()
    {
        $sql = "SELECT * FROM khuyen_mai";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
   
}
