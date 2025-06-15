<?php
require_once("config.php");
class Database
{
    private $host = DB_HOST;
    private $username = DB_USERNAME;
    private $password = DB_PASSWORD;
    private $dbname = DB_NAME;
    function connect()
    {
        $conn = mysqli_connect($this->host, $this->username, $this->password, $this->dbname);
        if (!$conn) {
            die("Kết nối CSDL thất bại: " . mysqli_connect_error());
        }
        return $conn;
    }
}
