<?php
class ChiTietDonHang
{
    private $conn;

    public $don_hang_id ;
    public $san_pham_id ;
    public $thuoc_tinh_id ;
    public $so_luong;
    public $don_gia;
    public $gia_giam;
    public $tong_gia;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachChiTietDonHang()
    {
        $sql = "SELECT * FROM chi_tiet_don_hang";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
    
    public function themChiTietDonHang()
    {
        $sql = "INSERT INTO chi_tiet_don_hang(don_hang_id, san_pham_id, thuoc_tinh_id, so_luong, don_gia, gia_giam, tong_gia) VALUES ";
        $sql .= "('" . $this->don_hang_id . "', '" . $this->san_pham_id . "', '" . $this->thuoc_tinh_id . "', '" . $this->so_luong  .  "','" . $this->don_gia . "','" . $this->gia_giam . "','"  . $this->tong_gia . "')";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
}
