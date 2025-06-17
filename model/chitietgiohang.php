<?php
class ChiTietGioHang
{
    private $conn;

    public $gio_hang_id;
    public $san_pham_id;
    public $thuoc_tinh_id;
    public $so_luong;
    public $ngay_them;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachChiTietGioHang()
    {
        $sql = "SELECT * FROM chi_tiet_gio_hang";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
  
    public function themChiTietGioHang()
    {
        $sql = "INSERT INTO chi_tiet_gio_hang (gio_hang_id, san_pham_id, thuoc_tinh_id, so_luong, ngay_them) VALUES ";
        $sql .= "('" . $this->gio_hang_id . "', '" . $this->san_pham_id . "', '" . $this->thuoc_tinh_id . "', '" . $this->so_luong  .  "','" . $this->ngay_them . "')";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
   
}
