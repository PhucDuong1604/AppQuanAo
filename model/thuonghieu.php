<?php
class ThuongHieu
{
    private $conn;

    public $ten  ;
    public $mo_ta  ;
    public $logo ;
    public $website ;
    public $trang_thai ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachThuongHieu()
    {
        $sql = "SELECT * FROM thuong_hieu";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
}