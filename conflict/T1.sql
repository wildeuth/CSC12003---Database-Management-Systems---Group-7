USE QLST
GO

-- Lost Update:

-- TH1: CapNhatHangKhachHangHangThang và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 2 là 1000000
-- T1 : Gọi thủ tục CapNhatHangKhachHangHangThang để cập nhật hạng khách hàng và reset TienTichLuy cho khách hàng
BEGIN TRANSACTION T1
EXEC CapNhatHangKhachHangHangThang

COMMIT TRANSACTION T1
SELECT * FROM KHACH_HANG

-- TH2: CapNhatSanPham và XuatHoaDon
-- Dữ liệu ban đầu: Số lượng tồn kho hiện tại của sản phẩm A là 10. Hóa đơn có id 1 mua 5 sản phẩm A
-- T1: Gọi XuatHoaDon và trừ 5 số lượng tồn kho hiện tại của sản phẩm A 
BEGIN TRANSACTION T1
EXEC XuatHoaDon 
	@MaHoaDon = 1
COMMIT TRANSACTION T1

-- TH3: XuatHoaDon và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 1 là 1000000
-- T1: Gọi XuatHoaDon và cộng thêm tiền tích lũy của khách hàng có id 1 là 220000
BEGIN TRANSACTION T1
EXEC XuatHoaDon 
	@MaHoaDon = 1

COMMIT TRANSACTION T1
SELECT * FROM KHACH_HANG

-- Phantom Read:

-- TH1: CapNhatSanPham và ThemSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm có id là 1
-- T1: Gọi CapNhatSanPham để sửa tên thành Sản phẩm A++
BEGIN TRANSACTION T1
EXEC dbo.CapNhatSanPham 
	@MaSanPham  = 1,
	@TenSanPham = N'Sản phẩm A++'

COMMIT TRANSACTION T1
SELECT * FROM SAN_PHAM

-- TH2: XoaSanPham và CapNhatSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm C
-- T1: Gọi CapNhatSanPham để đổi tên sản phẩm id 3 thành sản phẩm B++
BEGIN TRANSACTION T1
EXEC dbo.CapNhatSanPham 
	@MaSanPham  = 3,
	@TenSanPham = N'Sản phẩm C++'
	
COMMIT TRANSACTION T1
SELECT * FROM SAN_PHAM 

-- TH3: CapNhatDanhMucSanPham và XoaDanhMucSanPham
-- Dữ liệu ban đầu: Tồn tại danh mục A
-- T1: Gọi CapNhatDanhMucSanPham để đổi tên sản phẩm id 1 thành danh mục A++
BEGIN TRANSACTION T1
EXEC dbo.CapNhatDanhMucSanPham 
	@MaDanhMuc  = 1,
	@TenDanhMuc = N'Danh mục A++'

COMMIT TRANSACTION T1
SELECT * FROM DANH_MUC
-- Unrepeatable read: Không xảy ra vì không có đọc lại dữ liệu




