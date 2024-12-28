USE QLST
GO
-- Lost Update:

-- TH1: CapNhatHangKhachHangHangThang và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 2 là 1000000
-- T2 : Gọi thủ tục CapNhatHangKhachHangHangThang để cập nhật hạng khách hàng và reset TienTichLuy cho khách hàng
BEGIN TRANSACTION T2
EXEC CapNhatHangKhachHangHangThang
COMMIT TRANSACTION T2

SELECT * FROM KHACH_HANG
-- TH2: CapNhatSanPham và XuatHoaDon
-- Dữ liệu ban đầu: Số lượng tồn kho hiện tại của sản phẩm A là 10. Hóa đơn có id 1 mua 5 sản phẩm A
-- T2: Gọi XuatHoaDon và trừ 5 số lượng tồn kho hiện tại của sản phẩm A 
BEGIN TRANSACTION T2
EXEC XuatHoaDon 
	@MaHoaDon = 1
COMMIT TRANSACTION T2

SELECT * FROM CHI_TIET_HOA_DON	
SELECT * FROM SAN_PHAM
-- TH3: XuatHoaDon và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 1 là 1000000
-- T2: Gọi CapNhatThongTinKhachHang và cập nhật tiền tích lũy của khách hàng có id 1 là 2000000
BEGIN TRANSACTION T2
EXEC CapNhatThongTinKhachHang 
    @MaKhachHang = 1, 
    @TienTichLuy = 2000000

COMMIT TRANSACTION T2
SELECT * FROM KHACH_HANG
-- Phantom Read:

-- TH1: CapNhatSanPham và ThemSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm có id là 1, tên là sản phẩm A
-- T2: Gọi ThemSanPham để thêm sản phẩm A++
BEGIN TRANSACTION T2
EXEC dbo.ThemSanPham 
	@TenSanPham = N'Sản phẩm A++',
	@MoTa = 'Sản phẩm A++',
	@GiaNiemYet = 100000,
	@MaDanhMuc = 1,
	@MaNhaSanXuat = 1,
	@SoLuongTonKhoHienTai = 10,
	@SLSPTD = 10

COMMIT TRANSACTION T2
SELECT * FROM SAN_PHAM

-- TH2: XoaSanPham và CapNhatSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm C
-- T2: Gọi XoaSanPham để xóa sản phẩm id 3 
BEGIN TRANSACTION T2
EXEC dbo.XoaSanPham 
	@MaSanPham  = 3

COMMIT TRANSACTION T2
SELECT * FROM SAN_PHAM

-- TH3: CapNhatDanhMucSanPham và XoaDanhMucSanPham
-- Dữ liệu ban đầu: Tồn tại danh mục A
-- T2: Gọi XoaDanhMucSanPham để xóa danh mục id 1
BEGIN TRANSACTION T2
EXEC dbo.XoaDanhMucSanPham 
	@MaDanhMuc  = 1

COMMIT TRANSACTION T2
SELECT * FROM DANH_MUC
-- Unrepeatable read: Không xảy ra vì không có đọc lại dữ liệu

