<?php
class SanPham
{
    private $conn;

    public $ma_san_pham ;
    public $ten ;
    public $mo_ta ;
    public $danh_muc_id ;
    public $thuong_hieu_id ;
    public $gia ;
    public $gia_giam ;
    public $noi_bat ;
    public $trang_thai ;
    public $ngay_tao  ;
    public $ngay_cap_nhat ;
    
    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachSanPham()
    {
        $sql = "SELECT * FROM san_pham";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
   
}
