<?php
class DanhGiaSanPham
{
    private $conn;

    public $san_pham_id  ;
    public $nguoi_dung_id   ;
    public $diem  ;
    public $binh_luan ;
    public $ngay_danh_gia ;
    public $duoc_duyet ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachDanhGia()
    {
        $sql = "SELECT * FROM danh_gia_san_pham";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
    
    public function themDanhGia()
    {
        $sql = "INSERT INTO danh_gia_san_pham (san_pham_id, nguoi_dung_id, diem, binh_luan, ngay_danh_gia, duoc_duyet) VALUES ";
        $sql .= "('" . $this->san_pham_id . "', '" . $this->nguoi_dung_id . "', '" . $this->diem . "', '" . $this->binh_luan  . "','" . $this->gay_danh_gia . "','" . $this->duoc_duyet . "')";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
}
