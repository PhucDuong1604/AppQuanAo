<?php
class DonHang
{
    private $conn;

    public $ma_don_hang  ;
    public $nguoi_dung_id  ;
    public $ngay_dat   ;
    public $tong_tien ;
    public $phi_van_chuyen ;
    public $giam_gia ;
    public $thanh_tien  ;
    public $dia_chi_giao_hang ;
    public $dia_chi_thanh_toan ;
    public $phuong_thuc_thanh_toan  ;
    public $trang_thai_thanh_toan ;
    public $trang_thai_don_hang ;
    public $ma_theo_doi  ;
    public $ghi_chu ;

    public function __construct($conn)
    {
        $this->conn = $conn;
    }
    public function layDanhSachDonHang()
    {
        $sql = "SELECT * FROM don_hang";
        $result = mysqli_query($this->conn, $sql);
        return $result;
    }
    public function xoaDonHang()
    {
        $sql = "DELETE FROM don_hang WHERE ma_don_hang ='" . $this->ma_don_hang . "'";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
    public function themDonHang()
    {
        $sql = "INSERT INTO don_hang (ma_don_hang, nguoi_dung_id, ngay_dat, tong_tien, phi_van_chuyen, giam_gia, thanh_tien, dia_chi_giao_hang, dia_chi_thanh_toan, phuong_thuc_thanh_toan, trang_thai_thanh_toan, trang_thai_don_hang, ma_theo_doi, ghi_chu) VALUES ";
        $sql .= "('" . $this->ma_don_hang . "', '" . $this->nguoi_dung_id . "', '" . $this->ngay_dat . "', '" . $this->tong_tien  . "','" . $this->phi_van_chuyen . "','" . $this->giam_gia . "',";
        $sql .= "'" . $this->thanh_tien . "', '" . $this->dia_chi_giao_hang . "', '" . $this->dia_chi_thanh_toan . "', '" . $this->phuong_thuc_thanh_toan . "', '" . $this->trang_thai_thanh_toan . "', '" . $this->trang_thai_don_hang . "', '" . $this->ma_theo_doi . "', '" . $this->ghi_chu. "')";
        if (mysqli_query($this->conn, $sql)) {
            return true;
        } else {
            return mysqli_error($this->conn);
        }
    }
}
