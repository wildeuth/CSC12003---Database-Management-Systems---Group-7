-- Thủ tục chính: Thống kê số lượng khách hàng mua sản phẩm trong ngày:  sp_ThongKeKhachHangHangNgay
DECLARE @TongKhachHang INT;
EXEC sp_ThongKeKhachHangHangNgay @Ngay =  '2024-11-01 14:00:00.000', @Tong = @TongKhachHang OUTPUT;

---- Thủ tục: Lấy số lượng khách hàng đã mua sản phẩm: sp_LaySoLuongKhachHangMuaSanPham
exec sp_LaySoLuongKhachHangMuaSanPham @Ngay = '2024-11-01 14:00:00.000'

-- Thủ tục: Lấy danh sách sản pham đã bán trong ngày: sp_LayDanhSachSanPhamDaBan
exec sp_LayDanhSachSanPhamDaBan '2024-11-01 14:00:00.000'

-- Thủ tục chính: Tính tổng doanh thu hàng ngày
DECLARE @TongDThu DECIMAL(18, 2);

EXEC sp_TinhTongDoanhThuHangNgay @Ngay = '2024-11-01 14:00:00.000', @TongDThu = @TongDThu OUTPUT;

-- Thủ tục lấy danh sách hoá đơn trong ngày: sp_LayDanhSachHoaDonTrongNgay
exec sp_LayDanhSachHoaDonTrongNgay @Ngay = '2024-11-01 14:00:00.000'

CREATE OR ALTER PROCEDURE ThemPhanLoai
    @Loai NVARCHAR(20),
    @DieuKien MONEY,
    @GiaTri MONEY
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra nếu loại đã tồn tại
        IF EXISTS (SELECT 1 FROM PHAN_LOAI WITH (UPDLOCK, HOLDLOCK) WHERE Loai = @Loai)
            THROW 50000, 'Loại khách hàng đã tồn tại.', 1

        -- Kiểm tra tính hợp lệ của các giá trị
        IF @DieuKien < 0 OR @GiaTri < 0
            THROW 50000, 'Điều kiện hoặc giá trị không hợp lệ.', 1

        -- Thêm loại khách hàng mới
        INSERT INTO PHAN_LOAI (Loai, DieuKien, GiaTri)
        VALUES (@Loai, @DieuKien, @GiaTri)

        COMMIT TRAN
        PRINT N'Thêm loại khách hàng thành công.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Chuẩn bị dữ liệu
INSERT INTO PHAN_LOAI(Loai, DieuKien, GiaTri)
VALUES 
    (N'Thân thiết', 0, 0),
    (N'Đồng', 3000000, 100000),
    (N'Bạc', 5000000, 200000),
    (N'Vàng', 15000000, 500000),
    (N'Bạch kim', 30000000, 700000),
    (N'Kim cương', 50000000, 1200000);


INSERT INTO KHACH_HANG (HoTen, Email, DiaChi, NgaySinh, SoDienThoai, LoaiKhachHang, NgayDangKy, TienTichLuy)
VALUES 
(N'Nguyễn Văn A', 'nguyenvana@gmail.com', N'123 Đường A', '1985-12-05', '0909123456', N'Bạc', '2024-12-17', 5000000),
(N'Trần Thị B', 'tranthib@gmail.com', N'123 Đường A - Cập nhật', '1985-12-20', '0911223344', N'Bạc', '2024-12-20', 1000000),
(N'Lê Văn C', 'levanc@gmail.com', N'789 Đường C', '1988-12-15', '0987654321', N'Thân thiết', '2024-12-17', 0)

INSERT INTO DANH_MUC (TenDanhMuc, DaXoa) 
VALUES
(N'Danh mục A', 0),
(N'Danh mục B', 0),
(N'Danh mục C', 0);

INSERT INTO NHA_SAN_XUAT(TenNhaSanXuat, DaXoa) 
VALUES
(N'Nhà sản xuất A', 0),
(N'Nhà sản xuất B', 0),
(N'Nhà sản xuất C', 0);

INSERT INTO SAN_PHAM (TenSanPham, MoTa, GiaNiemYet, MaDanhMuc, MaNhaSanXuat, SoLuongTonKhoHienTai, SLSPTD, DaXoa)
VALUES 
(N'Sản phẩm A', N'Mô tả sản phẩm A', 50000, 1, 1, 10, 10, 0),
(N'Sản phẩm B', N'Mô tả sản phẩm B', 75000, 1, 2, 50, 20, 0),
(N'Sản phẩm C', N'Mô tả sản phẩm C', 120000, 2, 3, 200, 15, 0);

INSERT INTO KHUYEN_MAI (TenKhuyenMai, LoaiKhuyenMai, NgayBatDau, NgayKetThuc)
VALUES 
(N'Khuyến mãi A', N'Flash', '2024-12-29', '2024-12-30'),
(N'Khuyến mãi B', N'Combo', '2024-12-29', '2024-12-30'),
(N'Khuyến mãi C', N'Member', '2024-03-01', '2024-03-15');

INSERT INTO PHIEU_MUA_SAM (MaKhachHang, NgayDat, LaOnline, SuDungPhieu)
VALUES 
(1, '2024-01-02 14:30:00', 1, 0), -- Đơn hàng online, có đăng kí
(2, '2024-01-03 10:15:00', 0, 0), -- Khách hàng thường, mua tại cửa hàng
(3, '2024-01-04 11:45:00', 1, 0), -- Đơn hàng online, có đăng kí
(NULL, '2024-01-05 16:00:00', 0, 0), -- Khách hàng vãng lai, mua tại cửa hàng
(NULL, '2024-01-06 18:30:00', 1, 0), -- Đơn hàng online 
(NULL, '2024-01-07 20:15:00', 0, 0), -- Khách hàng thường, mua tại cửa hàng 
(NULL, '2024-01-01 09:00:00', 0, 0) -- Khách hàng vãng lai, mua tại cửa hàng

INSERT INTO CHI_TIET_PHIEU_MUA_SAM (MaPhieuMuaSam, MaSanPham, SoLuongDat)
VALUES 
-- Chi tiết cho phiếu mua sắm 1
(1, 1, 2),
(1, 3, 1),

-- Chi tiết cho phiếu mua sắm 2
(2, 2, 3),
(2, 3, 1),

-- Chi tiết cho phiếu mua sắm 3
(3, 1, 5),
(3, 2, 2),

-- Chi tiết cho phiếu mua sắm 4
(4, 2, 1),
(4, 3, 4),

-- Chi tiết cho phiếu mua sắm 5
(5, 1, 3),
(5, 2, 2),

-- Chi tiết cho phiếu mua sắm 6
(6, 3, 1),
(6, 1, 2),

-- Chi tiết cho phiếu mua sắm 7
(7, 1, 4),
(7, 3, 2);

INSERT INTO HOA_DON (MaPhieuMuaSam, PhieuMuaHang, TrangThaiThanhToan, TongTien, ThanhToan, NgayLap)
VALUES 
(1, NULL, 0, 220000, 220000, '2024-12-29'),
(2, NULL, 0, 345000, 345000, '2024-12-29'),
(3, NULL, 0, 400000, 400000, '2024-12-29'),
(4, NULL, 0, 555000, 555000, '2024-12-29'),
(5, NULL, 0, 300000, 300000, '2024-12-29'),
(6, NULL, 0, 220000, 220000, '2024-12-29'),
(7, NULL, 0, 440000, 440000, '2024-12-29');

INSERT INTO CHI_TIET_HOA_DON (MaHoaDon, MaSanPham, SoLuong, GiaBan)
VALUES
-- Chi tiết cho hóa đơn 1
(1, 1, 2, 50000),
(1, 3, 1, 120000),

-- Chi tiết cho hóa đơn 2
(2, 2, 3, 75000),
(2, 3, 1, 120000),

-- Chi tiết cho hóa đơn 3
(3, 1, 5, 50000),
(3, 2, 2, 75000),

-- Chi tiết cho hóa đơn 4
(4, 2, 1, 75000),
(4, 3, 4, 120000),

-- Chi tiết cho hóa đơn 5
(5, 1, 3, 50000),
(5, 2, 2, 75000),

-- Chi tiết cho hóa đơn 6
(6, 3, 1, 120000),
(6, 1, 2, 50000),

-- Chi tiết cho hóa đơn 7
(7, 1, 4, 50000),
(7, 3, 2, 120000);