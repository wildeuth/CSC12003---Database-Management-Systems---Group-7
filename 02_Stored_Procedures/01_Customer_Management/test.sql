USE QLST
GO

-- phân loại
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


SELECT * FROM PHAN_LOAI
ORDER BY DieuKien ASC


-- khách hàng
EXEC dbo.DangKyKhachHang 
    @HoTen = N'Nguyễn Văn A', 
    @Email = N'nguyenvana@gmail.com', 
    @DiaChi = N'123 Đường A', 
    @NgaySinh = '1985-12-05', 
    @SoDienThoai = N'0909123456'

EXEC dbo.DangKyKhachHang 
    @HoTen = N'Trần Thị B', 
    @Email = N'tranthib@gmail.com', 
    @DiaChi = N'456 Đường B', 
    @NgaySinh = '1990-12-20', 
    @SoDienThoai = N'0911223344'

EXEC dbo.DangKyKhachHang 
    @HoTen = N'Lê Văn C', 
    @Email = N'levanc@gmail.com', 
    @DiaChi = N'789 Đường C', 
    @NgaySinh = '1988-01-15', 
    @SoDienThoai = N'0933556677'

EXEC dbo.CapNhatThongTinKhachHang 
    @MaKhachHang = 2, 
    @Email = N'nguyenvana_updated@gmail.com', 
    @DiaChi = N'123 Đường A - Cập nhật'

EXEC dbo.CapNhatThongTinKhachHang 
    @MaKhachHang = 3, 
    @SoDienThoai = N'0987654321'


UPDATE KHACH_HANG SET TienTichLuy = 7200000, NgayDangKy = '2023-1-1' WHERE MaKhachHang = 2
UPDATE KHACH_HANG SET TienTichLuy = 60000000, NgayDangKy = '2023-1-1'  WHERE MaKhachHang = 3

EXEC dbo.CapNhatHangKhachHangHangThang

SELECT * FROM KHACH_HANG


-- phiếu mua hàng
EXEC dbo.TangPhieuMuaHangSinhNhat

SELECT * FROM PHIEU_MUA_HANG
SELECT * FROM THONG_BAO