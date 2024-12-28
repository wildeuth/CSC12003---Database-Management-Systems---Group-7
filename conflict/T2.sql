-- Lost Update:

-- TH1: CapNhatHangKhachHangHangThang và CapNhatThongTinKhachHang
-- T2 : Gọi thủ tục CapNhatHangKhachHangHangThang để cập nhật hạng khách hàng và reset TienTichLuy cho khách hàng
COMMIT TRANSACTION T2
EXEC CapNhatHangKhachHangHangThang
COMMIT TRANSACTION T2

-- TH2: CapNhatSanPham và XuatHoaDon
-- Dữ liệu ban đầu: Số lượng tồn kho hiện tại của sản phẩm A là 10. Hóa đơn có id 1 mua 5 sản phẩm A
-- T2: Gọi XuatHoaDon và trừ 5 số lượng tồn kho hiện tại của sản phẩm A 
COMMIT TRANSACTION T2
EXEC XuatHoaDon 
	@MaHoaDon = 1

COMMIT TRANSACTION T2

-- TH3: XuatHoaDon và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 1 là 1000000
-- T2: Gọi CapNhatThongTinKhachHang và cập nhật tiền tích lũy của khách hàng có id 1 là 2000000
BEGIN TRANSACTION T1
EXEC CapNhatThongTinKhachHang 
    @MaKhachHang = 3, 
    @TienTichLuy = 2000000

COMMIT TRANSACTION T1

-- Phantom Read:

-- TH1: TaoHoaDon và CapNhatChuongTrinhKhuyenMai
-- Dữ liệu ban đầu: Khuyến mãi A và B có ngày bắt đầu là 29/12/2024 và ngày kết thúc là 30/12/2024
-- T1: Gọi TaoHoaDon và lấy danh sách khuyến mãi khả dụng hiện tại và lấy được khuyến mãi A, B. Sau đó lấy lại danh sách thì không thấy B nữa
BEGIN TRANSACTION T1
EXEC CapNhatChuongTrinhKhuyenMai 
	@MaKhuyenMai = 2,
	@NgayBatDau = '2024-1-29',
	@NgayKetThuc = '2024-1-30'

COMMIT TRANSACTION T1

-- TH2: TaoHoaDon và ThemChuongTrinhKhuyenMai
-- Dữ liệu ban đầu: Khuyến mãi A có ngày bắt đầu là 29/12/2024 và ngày kết thúc là 30/12/2024
-- T1: Gọi CapNhatChuongTrinhKhuyenMai và cập nhật ngày bắt đầu và kết thúc của khuyến mãi B
BEGIN TRANSACTION T1
EXEC ThemChuongTrinhKhuyenMai 
	@TenKhuyenMai = N'Khuyến mãi D',
    @LoaiKhuyenMai = 'Flash',
    @NgayBatDau = '2024-12-29',
    @NgayKetThuc = '2024-12-30'

COMMIT TRANSACTION T1

-- TH3: XoaSanPham và CapNhatSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm C có id 3
-- T1: Gọi XoaSanPham để xóa sản phẩm 3
BEGIN TRANSACTION T1
EXEC XoaSanPham 
	@MaSanPham  = 3

COMMIT TRANSACTION T1

-- Unrepeatable read: Không xảy ra vì không có đọc lại dữ liệu
-- TH1: TaoHoaDon và CapNhatHangKhachHangHangThang
-- Dữ liệu ban đầu: Hạng của khách hàng id 3 là Bạc
-- T1: Gọi TaoHoaDon và áp dụng khuyến mãi member loại bạc cho sản phẩm
BEGIN TRANSACTION T1
EXEC CapNhatHangKhachHangHangThang

COMMIT TRANSACTION T1

-- TH2: TaoHoaDon và CapNhatSanPham
-- Dữ liệu ban đầu: Giá niêm yết của sản phẩm A là 100000
-- T1: Gọi CapNhatSanPham và cập nhật giá niêm yết là 200000
BEGIN TRANSACTION T1
EXEC CapNhatSanPham 
	@MaSanPham = 1,
	@GiaNiemYet = 200000

COMMIT TRANSACTION T1
