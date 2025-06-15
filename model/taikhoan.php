<?php
class TaiKhoan
{
    private $conn;

    public $mat_khau;
    public $email;
    public $ho_ten;
    public $so_dien_thoai;
    public $gioi_tinh;
    public $ngay_sinh;
    public $trang_thai;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachTaiKhoan()
    {
        $sql = "SELECT * FROM tai_khoan";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
   
    public function themTaiKhoan()
    {
        $sql = "INSERT INTO tai_khoan( mat_khau, email, ho_ten, so_dien_thoai, gioi_tinh, ngay_sinh, trang_thai) VALUES ";
        $sql .= "( '" . $this->mat_khau . "', '". $this->email . "', '" . $this->ho_ten . "', '" . $this->so_dien_thoai . "'," ;
        $sql .= "'"  . $this->gioi_tinh . "', '"  . $this->ngay_sinh . "', '"  . $this->trang_thai . "')";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
}
