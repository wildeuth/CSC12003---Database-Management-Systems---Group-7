-- Lost Update:

-- Chuẩn bị dữ liệu
EXEC dbo.ThemPhanLoai 
    @Loai = N'Thân thiết',
    @DieuKien = 0,
    @GiaTri = 0

EXEC dbo.ThemPhanLoai 
    @Loai = N'Đồng',
    @DieuKien = 3000000,
    @GiaTri = 100000

EXEC dbo.ThemPhanLoai 
    @Loai = N'Bạc',
    @DieuKien = 5000000,
    @GiaTri = 200000

EXEC dbo.ThemPhanLoai 
    @Loai = N'Vàng',
    @DieuKien = 15000000,
    @GiaTri = 500000

EXEC dbo.ThemPhanLoai 
    @Loai = N'Bạch kim',
    @DieuKien = 30000000,
    @GiaTri = 700000

EXEC dbo.ThemPhanLoai 
    @Loai = N'Kim cương',
    @DieuKien = 50000000,
    @GiaTri = 1200000

-- khách hàng
EXEC dbo.DangKyKhachHang 
    @HoTen = N'Nguyễn Văn A', 
    @Email = N'nguyenvana@gmail.com', 
    @DiaChi = N'123 Đường A', 
    @NgaySinh = '1985-12-05', 
    @SoDienThoai = N'0909123456'

select * from KHACH_HANG

-- TH1: CapNhatHangKhachHangHangThang và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 2 là 1000000
-- T1: Gọi thủ tục CapNhatThongTinKhachHang để cập nhật tiền tích lũy và hạng của khách hàng có id 2
BEGIN TRANSACTION T1
EXEC CapNhatThongTinKhachHang 
    @MaKhachHang = 2, 
    @TienTichLuy = 7000000,
	@LoaiKhachHang = N'Vàng'
COMMIT TRANSACTION T1

ROLLBACK TRANSACTION
select * from PHAN_LOAI

-- TH2: CapNhatSanPham và XuatHoaDon
-- Dữ liệu ban đầu: Số lượng tồn kho hiện tại của sản phẩm A là 10. Hóa đơn có id 1 mua 5 sản phẩm A
-- T1: Gọi thủ tục CapNhatSanPham và cập nhật số lượng tồn kho hiện tại của sản phẩm A là 6
BEGIN TRANSACTION T1
EXEC CapNhatSanPham 
	@TenSanPham = N'Sản phẩm A',
	@SoLuongTonKhoHienTai = 6

COMMIT TRANSACTION T1

-- TH3: XuatHoaDon và CapNhatThongTinKhachHang
-- Dữ liệu ban đầu: Tiền tích lũy của khách hàng có id 1 là 1000000
-- T1: Gọi XuatHoaDon và cộng thêm tiền tích lũy của khách hàng có id 1 là 500000
BEGIN TRANSACTION T1
EXEC XuatHoaDon 
	@MaHoaDon = 2

COMMIT TRANSACTION T1

-- Phantom Read:

-- TH1: TaoHoaDon và CapNhatChuongTrinhKhuyenMai
-- Dữ liệu ban đầu: Khuyến mãi A và B có ngày bắt đầu là 29/12/2024 và ngày kết thúc là 30/12/2024
-- T1: Gọi TaoHoaDon và lấy danh sách khuyến mãi khả dụng hiện tại và lấy được khuyến mãi A, B. Sau đó lấy lại danh sách thì không thấy B nữa
BEGIN TRANSACTION T1
EXEC TaoHoaDon 
	@MaPhieuMuaSam = 3

COMMIT TRANSACTION T1

-- TH2: TaoHoaDon và CapNhatChuongTrinhKhuyenMai
-- Dữ liệu ban đầu: Khuyến mãi A có ngày bắt đầu là 29/12/2024 và ngày kết thúc là 30/12/2024
-- T1: Gọi TaoHoaDon và lấy danh sách khuyến mãi khả dụng hiện tại và lấy được khuyến mãi A. Sau đó lấy lại danh sách thì thấy có thêm B
BEGIN TRANSACTION T1
EXEC TaoHoaDon 
	@MaPhieuMuaSam = 4

COMMIT TRANSACTION T1

-- TH3: XoaSanPham và CapNhatSanPham
-- Dữ liệu ban đầu: Tồn tại sản phẩm C
-- T1: Gọi CapNhatSanPham để đổi tên sản phẩm id 3 thành sản phẩm C++
BEGIN TRANSACTION T1
EXEC CapNhatSanPham 
	@MaSanPham  = 3
	@TenSanPham = N'Sản phẩm C++'

COMMIT TRANSACTION T1

-- TH3: ThemSanPham và CapNhatSanPham
-- Dữ liệu ban đầu: Chưa tồn tại tên sản phẩm B
-- T1: Gọi TaoHoaDon và lấy danh sách khuyến mãi khả dụng hiện tại và lấy được khuyến mãi A. Sau đó lấy lại danh sách thì thấy có thêm B
BEGIN TRANSACTION T1
EXEC CapNhatSanPham 
	@MaSanPham  = 2
	@TenSanPham = N'Sản phẩm B'

COMMIT TRANSACTION T1

-- Unrepeatable read: Không xảy ra vì không có đọc lại dữ liệu
-- TH1: TaoHoaDon và CapNhatHangKhachHangHangThang
-- Dữ liệu ban đầu: Hạng của khách hàng id 3 là Bạc
-- T1: Gọi TaoHoaDon và áp dụng khuyến mãi member loại bạc cho sản phẩm
BEGIN TRANSACTION T1
EXEC TaoHoaDon 
	@MaPhieuMuaSam = 5

COMMIT TRANSACTION T1

-- TH2: TaoHoaDon và CapNhatSanPham
-- Dữ liệu ban đầu: Giá niêm yết của sản phẩm A là 100000
-- T1: Gọi TaoHoaDon và thêm vào chi tiết hóa đơn với giá bán là 100000
BEGIN TRANSACTION T1
EXEC TaoHoaDon 
	@MaPhieuMuaSam = 6

COMMIT TRANSACTION T1



