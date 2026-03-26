USE QLST
GO

-- Nhà sản xuất
-- Kiểm tra thêm nhà sản xuất
EXEC dbo.ThemNhaSanXuat @TenNhaSanXuat = N'Nhà sản xuất A'
EXEC dbo.ThemNhaSanXuat @TenNhaSanXuat = N'Nhà sản xuất B'
GO

-- Kiểm tra cập nhật nhà sản xuất
EXEC dbo.CapNhatNhaSanXuat @MaNhaSanXuat = 1, @TenNhaSanXuat = N'Nhà sản xuất A (Cập nhật)'
EXEC dbo.CapNhatNhaSanXuat @MaNhaSanXuat = 2, @TenNhaSanXuat = N'Nhà sản xuất B (Cập nhật)'
GO

-- Kiểm tra xóa nhà sản xuất
EXEC dbo.ThemNhaSanXuat @TenNhaSanXuat = N'Nhà sản xuất C'
EXEC dbo.ThemNhaSanXuat @TenNhaSanXuat = N'Nhà sản xuất D'
EXEC dbo.XoaNhaSanXuat @MaNhaSanXuat = 3
EXEC dbo.XoaNhaSanXuat @MaNhaSanXuat = 4
GO

SELECT * FROM NHA_SAN_XUAT
GO


-- Danh mục
-- Kiểm tra thêm danh mục sản phẩm
EXEC dbo.ThemDanhMucSanPham @TenDanhMuc = N'Danh mục 1'
EXEC dbo.ThemDanhMucSanPham @TenDanhMuc = N'Danh mục 2'
GO

-- Kiểm tra cập nhật danh mục sản phẩm
EXEC dbo.CapNhatDanhMucSanPham @MaDanhMuc = 1, @TenDanhMuc = N'Danh mục 1 (Cập nhật)'
EXEC dbo.CapNhatDanhMucSanPham @MaDanhMuc = 2, @TenDanhMuc = N'Danh mục 2 (Cập nhật)'
GO

-- Kiểm tra xóa danh mục sản phẩm
EXEC dbo.ThemDanhMucSanPham @TenDanhMuc = N'Danh mục 3'
EXEC dbo.ThemDanhMucSanPham @TenDanhMuc = N'Danh mục 4'
EXEC dbo.XoaDanhMucSanPham @MaDanhMuc = 3
EXEC dbo.XoaDanhMucSanPham @MaDanhMuc = 4
GO

SELECT * FROM DANH_MUC
GO


-- Sản phẩm
-- Kiểm tra thêm sản phẩm
EXEC dbo.ThemSanPham 
    @TenSanPham = N'Sản phẩm 1', 
    @MoTa = N'Mô tả sản phẩm 1', 
    @GiaNiemYet = 1000000, 
    @MaDanhMuc = 1, 
    @MaNhaSanXuat = 1, 
    @SoLuongTonKhoHienTai = 50, 
    @SLSPTD = 100

EXEC dbo.ThemSanPham 
    @TenSanPham = N'Sản phẩm 2', 
    @MoTa = N'Mô tả sản phẩm 2', 
    @GiaNiemYet = 1500000, 
    @MaDanhMuc = 2, 
    @MaNhaSanXuat = 2, 
    @SoLuongTonKhoHienTai = 30, 
    @SLSPTD = 200

-- Kiểm tra cập nhật sản phẩm
EXEC dbo.CapNhatSanPham 
    @MaSanPham = 1, 
    @TenSanPham = N'Sản phẩm 1 (Cập nhật)', 
    @MoTa = N'Mô tả sản phẩm 1 (Cập nhật)', 
    @GiaNiemYet = 1200000, 
    @MaDanhMuc = 1, 
    @MaNhaSanXuat = 1, 
    @SoLuongTonKhoHienTai = 60, 
    @SLSPTD = 150

EXEC dbo.CapNhatSanPham 
    @MaSanPham = 2, 
    @TenSanPham = N'Sản phẩm 2 (Cập nhật)', 
    @MoTa = N'Mô tả sản phẩm 2 (Cập nhật)', 
    @GiaNiemYet = 1800000, 
    @MaDanhMuc = 2, 
    @MaNhaSanXuat = 2, 
    @SoLuongTonKhoHienTai = 40, 
    @SLSPTD = 250
GO

-- Kiểm tra xóa sản phẩm
EXEC dbo.ThemSanPham 
    @TenSanPham = N'Sản phẩm 1', 
    @MoTa = N'Mô tả sản phẩm 1', 
    @GiaNiemYet = 1000000, 
    @MaDanhMuc = 1, 
    @MaNhaSanXuat = 1, 
    @SoLuongTonKhoHienTai = 50, 
    @SLSPTD = 100

EXEC dbo.ThemSanPham 
    @TenSanPham = N'Sản phẩm 2', 
    @MoTa = N'Mô tả sản phẩm 2', 
    @GiaNiemYet = 1500000, 
    @MaDanhMuc = 2, 
    @MaNhaSanXuat = 2, 
    @SoLuongTonKhoHienTai = 30, 
    @SLSPTD = 200
GO

EXEC dbo.XoaSanPham @MaSanPham = 3
EXEC dbo.XoaSanPham @MaSanPham = 4
GO

SELECT * FROM SAN_PHAM
GO


-- Kiểm tra thêm chương trình khuyến mãi
DECLARE @ChiTietKhuyenMai DanhSachKhuyenMaiChiTietType
INSERT INTO @ChiTietKhuyenMai VALUES (1, 10, 100, NULL, NULL), (2, 20, 50, 2, NULL)

EXEC dbo.ThemChuongTrinhKhuyenMai 
    @TenKhuyenMai = N'Khuyến mãi Tết', 
    @LoaiKhuyenMai = N'Comboa', 
    @NgayBatDau = '1/1/2024', 
    @NgayKetThuc = '2/2/2024', 
    @DanhSachKhuyenMaiChiTiet = @ChiTietKhuyenMai
GO

-- Kiểm tra cập nhật chương trình khuyến mãi
DECLARE @ChiTietKhuyenMaiUpdated DanhSachKhuyenMaiChiTietType
INSERT INTO @ChiTietKhuyenMaiUpdated VALUES (1, 15, 80, 2, NULL), (2, 25, 60, 1, NULL)

EXEC dbo.CapNhatChuongTrinhKhuyenMai 
    @MaKhuyenMai = 1, 
    @TenKhuyenMai = N'Khuyến mãi Tết 2', 
    @NgayBatDau = '2024-01-01', 
    @NgayKetThuc = '2024-02-15', 
    @DanhSachKhuyenMaiChiTiet = @ChiTietKhuyenMaiUpdated
GO

SELECT * FROM KHUYEN_MAI 
SELECT * FROM CHI_TIET_KHUYEN_MAI_FLASH
SELECT * FROM CHI_TIET_KHUYEN_MAI_COMBO
SELECT * FROM CHI_TIET_KHUYEN_MAI_MEMBER
GO