<?php
header("Content-Type: application/json"); // Đặt Content-Type là JSON
require_once("../../config/db.php"); // Đảm bảo đường dẫn đến file kết nối CSDL của bạn là chính xác

// Khởi tạo kết nối cơ sở dữ liệu
$db = new Database();
$conn = $db->connect();

// Xử lý các yêu cầu dựa trên phương thức HTTP
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'POST':
        // Xử lý yêu cầu thêm hoặc cập nhật sản phẩm vào giỏ hàng
        handleAddToCart($conn);
        break;
    case 'GET':
        // Xử lý yêu cầu lấy thông tin giỏ hàng
        handleGetCart($conn);
        break;
    default:
        // Phương thức yêu cầu không hợp lệ
        echo json_encode(array("message" => "Phương thức yêu cầu không hợp lệ. Chỉ chấp nhận POST hoặc GET."));
        break;
}

// Đóng kết nối cơ sở dữ liệu sau khi hoàn thành
mysqli_close($conn);

/**
 * Hàm xử lý yêu cầu thêm hoặc cập nhật sản phẩm vào giỏ hàng.
 * Yêu cầu POST với JSON body chứa:
 * - nguoi_dung_id: ID của người dùng (INT)
 * - san_pham_id: ID của sản phẩm (INT)
 * - thuoc_tinh_id: ID của chi tiết sản phẩm/thuộc tính (INT)
 * - so_luong: Số lượng sản phẩm muốn thêm/cập nhật (INT)
 */
function handleAddToCart($conn) {
    $input = json_decode(file_get_contents("php://input"), true);

    // Kiểm tra các trường bắt buộc
    if (
        !isset($input['nguoi_dung_id']) ||
        !isset($input['san_pham_id']) ||
        !isset($input['thuoc_tinh_id']) ||
        !isset($input['so_luong']) ||
        !is_numeric($input['so_luong']) || $input['so_luong'] <= 0
    ) {
        echo json_encode(array("message" => "Vui lòng cung cấp đủ thông tin và số lượng hợp lệ: nguoi_dung_id, san_pham_id, thuoc_tinh_id, so_luong."));
        return;
    }

    $nguoiDungId = $input['nguoi_dung_id'];
    $sanPhamId = $input['san_pham_id'];
    $thuocTinhId = $input['thuoc_tinh_id'];
    $soLuong = (int)$input['so_luong']; // Chuyển sang kiểu số nguyên

    // 1. Tìm hoặc tạo giỏ hàng cho người dùng
    $gioHangId = null;
    $sqlFindCart = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmtFindCart = mysqli_prepare($conn, $sqlFindCart);
    if ($stmtFindCart === false) {
        echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn tìm giỏ hàng: " . mysqli_error($conn)));
        return;
    }
    mysqli_stmt_bind_param($stmtFindCart, "i", $nguoiDungId);
    mysqli_stmt_execute($stmtFindCart);
    $resultFindCart = mysqli_stmt_get_result($stmtFindCart);

    if ($resultFindCart && mysqli_num_rows($resultFindCart) > 0) {
        $row = mysqli_fetch_assoc($resultFindCart);
        $gioHangId = $row['id'];
    } else {
        // Tạo giỏ hàng mới nếu chưa có
        $sqlCreateCart = "INSERT INTO gio_hang (nguoi_dung_id) VALUES (?)";
        $stmtCreateCart = mysqli_prepare($conn, $sqlCreateCart);
        if ($stmtCreateCart === false) {
            echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn tạo giỏ hàng: " . mysqli_error($conn)));
            return;
        }
        mysqli_stmt_bind_param($stmtCreateCart, "i", $nguoiDungId);
        if (!mysqli_stmt_execute($stmtCreateCart)) {
            echo json_encode(array("message" => "Lỗi khi tạo giỏ hàng mới: " . mysqli_stmt_error($stmtCreateCart)));
            mysqli_stmt_close($stmtCreateCart);
            return;
        }
        $gioHangId = mysqli_insert_id($conn);
        mysqli_stmt_close($stmtCreateCart);
    }
    mysqli_stmt_close($stmtFindCart);

    if ($gioHangId === null) {
        echo json_encode(array("message" => "Không thể tìm hoặc tạo giỏ hàng."));
        return;
    }

    // 2. Kiểm tra xem sản phẩm đã tồn tại trong chi_tiet_gio_hang chưa
    $sqlFindItem = "SELECT id, so_luong FROM chi_tiet_gio_hang WHERE gio_hang_id = ? AND san_pham_id = ? AND thuoc_tinh_id = ?";
    $stmtFindItem = mysqli_prepare($conn, $sqlFindItem);
    if ($stmtFindItem === false) {
        echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn tìm chi tiết giỏ hàng: " . mysqli_error($conn)));
        return;
    }
    mysqli_stmt_bind_param($stmtFindItem, "iii", $gioHangId, $sanPhamId, $thuocTinhId);
    mysqli_stmt_execute($stmtFindItem);
    $resultFindItem = mysqli_stmt_get_result($stmtFindItem);

    $isUpdated = false;
    if ($resultFindItem && mysqli_num_rows($resultFindItem) > 0) {
        // Sản phẩm đã có trong giỏ, cập nhật số lượng
        $row = mysqli_fetch_assoc($resultFindItem);
        $existingQuantity = $row['so_luong'];
        $cartItemId = $row['id'];
        $newQuantity = $existingQuantity + $soLuong;

        $sqlUpdateItem = "UPDATE chi_tiet_gio_hang SET so_luong = ?, ngay_them = CURRENT_TIMESTAMP WHERE id = ?";
        $stmtUpdateItem = mysqli_prepare($conn, $sqlUpdateItem);
        if ($stmtUpdateItem === false) {
            echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn cập nhật giỏ hàng: " . mysqli_error($conn)));
            mysqli_stmt_close($stmtFindItem);
            return;
        }
        mysqli_stmt_bind_param($stmtUpdateItem, "ii", $newQuantity, $cartItemId);
        if (mysqli_stmt_execute($stmtUpdateItem)) {
            echo json_encode(array("success" => true, "message" => "Cập nhật số lượng sản phẩm trong giỏ hàng thành công.", "gio_hang_id" => $gioHangId, "chi_tiet_gio_hang_id" => $cartItemId));
            $isUpdated = true;
        } else {
            echo json_encode(array("message" => "Lỗi khi cập nhật số lượng sản phẩm trong giỏ hàng: " . mysqli_stmt_error($stmtUpdateItem)));
        }
        mysqli_stmt_close($stmtUpdateItem);
    } else {
        // Sản phẩm chưa có trong giỏ, thêm mới
        $sqlInsertItem = "INSERT INTO chi_tiet_gio_hang (gio_hang_id, san_pham_id, thuoc_tinh_id, so_luong) VALUES (?, ?, ?, ?)";
        $stmtInsertItem = mysqli_prepare($conn, $sqlInsertItem);
        if ($stmtInsertItem === false) {
            echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn thêm chi tiết giỏ hàng: " . mysqli_error($conn)));
            mysqli_stmt_close($stmtFindItem);
            return;
        }
        mysqli_stmt_bind_param($stmtInsertItem, "iiii", $gioHangId, $sanPhamId, $thuocTinhId, $soLuong);
        if (mysqli_stmt_execute($stmtInsertItem)) {
            $newCartItemId = mysqli_insert_id($conn);
            echo json_encode(array("success" => true, "message" => "Thêm sản phẩm vào giỏ hàng thành công.", "gio_hang_id" => $gioHangId, "chi_tiet_gio_hang_id" => $newCartItemId));
            $isUpdated = true;
        } else {
            echo json_encode(array("message" => "Lỗi khi thêm sản phẩm vào giỏ hàng: " . mysqli_stmt_error($stmtInsertItem)));
        }
        mysqli_stmt_close($stmtInsertItem);
    }
    mysqli_stmt_close($stmtFindItem);
}

/**
 * Hàm xử lý yêu cầu lấy thông tin giỏ hàng của người dùng.
 * Yêu cầu GET với tham số URL 'nguoi_dung_id'.
 */
function handleGetCart($conn) {
    if (!isset($_GET['nguoi_dung_id'])) {
        echo json_encode(array("message" => "Vui lòng cung cấp 'nguoi_dung_id' để lấy thông tin giỏ hàng."));
        return;
    }

    $nguoiDungId = $_GET['nguoi_dung_id'];

    // Truy vấn để lấy ID giỏ hàng
    $sqlFindCart = "SELECT id FROM gio_hang WHERE nguoi_dung_id = ?";
    $stmtFindCart = mysqli_prepare($conn, $sqlFindCart);
    if ($stmtFindCart === false) {
        echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn tìm giỏ hàng: " . mysqli_error($conn)));
        return;
    }
    mysqli_stmt_bind_param($stmtFindCart, "i", $nguoiDungId);
    mysqli_stmt_execute($stmtFindCart);
    $resultFindCart = mysqli_stmt_get_result($stmtFindCart);

    if ($resultFindCart && mysqli_num_rows($resultFindCart) === 0) {
        echo json_encode(array("message" => "Không tìm thấy giỏ hàng cho người dùng này."));
        mysqli_stmt_close($stmtFindCart);
        return;
    }

    $gioHangData = mysqli_fetch_assoc($resultFindCart);
    $gioHangId = $gioHangData['id'];
    mysqli_stmt_close($stmtFindCart);

    // Truy vấn để lấy chi tiết các sản phẩm trong giỏ hàng
    // Nối với bảng san_pham và chi_tiet_san_pham để lấy thông tin đầy đủ
    $sqlGetCartItems = "
        SELECT
            ctgh.id AS chi_tiet_gio_hang_id,
            ctgh.so_luong,
            ctgh.ngay_them,
            sp.id AS san_pham_id,
            sp.ma_san_pham,
            sp.ten AS ten_san_pham,
            sp.gia,
            sp.gia_giam,
            ctsp.id AS thuoc_tinh_id,
            ctsp.kich_co,
            ctsp.mau_sac,
            ctsp.chat_lieu,
            ctsp.trong_luong,
            ctsp.so_luong_ton,
            (
                SELECT duong_dan_anh
                FROM hinh_anh_san_pham
                WHERE san_pham_id = sp.id AND anh_chinh = TRUE
                ORDER BY thu_tu ASC
                LIMIT 1
            ) AS anh_chinh_url
        FROM
            chi_tiet_gio_hang ctgh
        JOIN
            san_pham sp ON ctgh.san_pham_id = sp.id
        JOIN
            chi_tiet_san_pham ctsp ON ctgh.thuoc_tinh_id = ctsp.id
        WHERE
            ctgh.gio_hang_id = ?
        ORDER BY
            ctgh.ngay_them DESC;
    ";

    $stmtGetCartItems = mysqli_prepare($conn, $sqlGetCartItems);
    if ($stmtGetCartItems === false) {
        echo json_encode(array("message" => "Lỗi chuẩn bị truy vấn chi tiết giỏ hàng: " . mysqli_error($conn)));
        return;
    }
    mysqli_stmt_bind_param($stmtGetCartItems, "i", $gioHangId);
    mysqli_stmt_execute($stmtGetCartItems);
    $resultGetCartItems = mysqli_stmt_get_result($stmtGetCartItems);

    $cartItems = [];
    if ($resultGetCartItems && mysqli_num_rows($resultGetCartItems) > 0) {
        while ($row = mysqli_fetch_assoc($resultGetCartItems)) {
            $cartItems[] = $row;
        }
    }

    echo json_encode(array(
        "gio_hang_id" => $gioHangId,
        "nguoi_dung_id" => $nguoiDungId,
        "items" => $cartItems
    ));

    mysqli_stmt_close($stmtGetCartItems);
}
?>
