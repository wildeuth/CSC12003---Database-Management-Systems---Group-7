USE QLST
GO
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

insert KHACH_HANG values (1, N'Nguyễn Văn A', 'nguyenvana@gmail.com', N'123 Đường A', '1985-12-05', '0909123456', N'Bạc', '2024-12-17', 5000000)
insert KHACH_HANG values (2, N'Trần Thị B', 'tranthib@gmail.com', N'123 Đường A - Cập nhật', '1985-12-20', '0911223344', N'Bạc', '2024-12-20', 1000000)
insert KHACH_HANG values (3, N'Lê Văn C', 'levanc@gmail.com', N'789 Đường C', '1988-12-15', N'Bạc', '0987654321', N'Thân thiết', '2024-12-17', 0)

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
