<?php
class HinhAnh
{
    private $conn;

    public $san_pham_id  ;
    public $duong_dan_anh   ;
    public $anh_chinh ;
    public $thu_tu ;
    
    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachHinhAnh()
    {
        $sql = "SELECT * FROM hinh_anh_san_pham";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
   
}
