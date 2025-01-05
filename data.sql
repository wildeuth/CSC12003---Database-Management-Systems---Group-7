USE QLST
GO

DBCC CHECKIDENT ('KHACH_HANG', RESEED, 0);
DBCC CHECKIDENT ('KHUYEN_MAI', RESEED, 0);
DBCC CHECKIDENT ('DANH_MUC', RESEED, 0);
DBCC CHECKIDENT ('NHA_SAN_XUAT', RESEED, 0);
DBCC CHECKIDENT ('PHIEU_MUA_SAM', RESEED, 0);
DBCC CHECKIDENT ('HOA_DON', RESEED, 0);
DBCC CHECKIDENT ('SAN_PHAM', RESEED, 0);
DBCC CHECKIDENT ('CHI_TIET_HOA_DON', RESEED, 0);
GO

DELETE FROM CHI_TIET_PHIEU_MUA_SAM
DELETE FROM CHI_TIET_HOA_DON
GO


DELETE FROM KHUYEN_MAI
DELETE FROM SAN_PHAM
DELETE FROM DANH_MUC
DELETE FROM NHA_SAN_XUAT
GO

DELETE FROM HOA_DON
DELETE FROM PHIEU_MUA_SAM
DELETE FROM KHACH_HANG
DELETE FROM PHAN_LOAI
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
GO

INSERT INTO KHACH_HANG (HoTen, Email, DiaChi, NgaySinh, SoDienThoai, LoaiKhachHang, NgayDangKy, TienTichLuy)
VALUES 
(N'Nguyễn Văn A', 'nguyenvana@gmail.com', N'123 Đường A', '1985-12-05', '0909123456', N'Bạc', '2022-12-17', 5000000),
(N'Trần Thị B', 'tranthib@gmail.com', N'123 Đường A - Cập nhật', '1985-12-20', '0911223344', N'Bạc', '2022-12-20', 1000000),
(N'Lê Văn C', 'levanc@gmail.com', N'789 Đường C', '1988-12-15', '0987654321', N'Thân thiết', '2022-12-17', 0)
GO

INSERT INTO DANH_MUC (TenDanhMuc, DaXoa) 
VALUES
(N'Danh mục A', 0),
(N'Danh mục B', 0),
(N'Danh mục C', 0);
GO

INSERT INTO NHA_SAN_XUAT(TenNhaSanXuat, DaXoa) 
VALUES
(N'Nhà sản xuất A', 0),
(N'Nhà sản xuất B', 0),
(N'Nhà sản xuất C', 0);
GO

INSERT INTO SAN_PHAM (TenSanPham, MoTa, GiaNiemYet, MaDanhMuc, MaNhaSanXuat, SoLuongTonKhoHienTai, SLSPTD, DaXoa)
VALUES 
(N'Sản phẩm A', N'Mô tả sản phẩm A', 50000, 1, 1, 10, 10, 0),
(N'Sản phẩm B', N'Mô tả sản phẩm B', 75000, 1, 2, 50, 20, 0),
(N'Sản phẩm C', N'Mô tả sản phẩm C', 120000, 2, 3, 200, 15, 0);
GO

INSERT INTO KHUYEN_MAI (TenKhuyenMai, LoaiKhuyenMai, NgayBatDau, NgayKetThuc)
VALUES 
(N'Khuyến mãi A', N'Flash', '2024-12-29', '2024-12-30'),
(N'Khuyến mãi B', N'Combo', '2024-12-29', '2024-12-30'),
(N'Khuyến mãi C', N'Member', '2024-03-01', '2024-03-15');
GO

INSERT INTO PHIEU_MUA_SAM (MaKhachHang, NgayDat, LaOnline, SuDungPhieu)
VALUES 
(1, '2024-01-02 14:30:00', 1, 0), -- Đơn hàng online, có đăng kí
(2, '2024-01-03 10:15:00', 0, 0), -- Khách hàng thường, mua tại cửa hàng
(3, '2024-01-04 11:45:00', 1, 0), -- Đơn hàng online, có đăng kí
(NULL, '2024-01-05 16:00:00', 0, 0), -- Khách hàng vãng lai, mua tại cửa hàng
(NULL, '2024-01-06 18:30:00', 1, 0), -- Đơn hàng online 
(NULL, '2024-01-07 20:15:00', 0, 0), -- Khách hàng thường, mua tại cửa hàng 
(NULL, '2024-01-01 09:00:00', 0, 0) -- Khách hàng vãng lai, mua tại cửa hàng
GO

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
GO

INSERT INTO HOA_DON (MaPhieuMuaSam, PhieuMuaHang, TrangThaiThanhToan, TongTien, ThanhToan, NgayLap)
VALUES 
(1, NULL, 0, 220000, 220000, '2024-12-29'),
(2, NULL, 0, 345000, 345000, '2024-12-29'),
(3, NULL, 0, 400000, 400000, '2024-12-29'),
(4, NULL, 0, 555000, 555000, '2024-12-29'),
(5, NULL, 0, 300000, 300000, '2024-12-29'),
(6, NULL, 0, 220000, 220000, '2024-12-29'),
(7, NULL, 0, 440000, 440000, '2024-12-29');
GO

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
GO

/*
SELECT * FROM CHI_TIET_PHIEU_MUA_SAM
SELECT * FROM CHI_TIET_HOA_DON


SELECT * FROM KHUYEN_MAI
SELECT * FROM SAN_PHAM
SELECT * FROM DANH_MUC
SELECT * FROM NHA_SAN_XUAT

SELECT * FROM HOA_DON
SELECT * FROM PHIEU_MUA_SAM
SELECT * FROM KHACH_HANG
SELECT * FROM PHAN_LOAI
*/
