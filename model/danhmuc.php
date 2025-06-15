<?php
class DanhMuc
{
    private $conn;

    public $ten  ;
    public $mo_ta  ;
    public $danh_muc_cha ;
    public $trang_thai ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachDanhMuc()
    {
        $sql = "SELECT * FROM danh_muc";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
}
