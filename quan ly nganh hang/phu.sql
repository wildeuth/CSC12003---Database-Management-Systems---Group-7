USE QLST
GO

CREATE OR ALTER PROCEDURE TaoMaKhuyenMai
    @TenKhuyenMai NVARCHAR(200),
    @LoaiKhuyenMai NVARCHAR(10),
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    -- Kiểm tra loại khuyến mãi hợp lệ
    IF @LoaiKhuyenMai NOT IN ('Flash', 'Combo', 'Member')
        THROW 50000, 'Loại khuyến mãi không hợp lệ.', 1

    -- Kiểm tra ngày kết thúc >= ngày bắt đầu
    IF @NgayKetThuc < @NgayBatDau
        THROW 50000, 'Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.', 1

    -- Thêm khuyến mãi mới và lấy ID
    INSERT INTO KHUYEN_MAI (TenKhuyenMai, LoaiKhuyenMai, NgayBatDau, NgayKetThuc)
    VALUES (@TenKhuyenMai, @LoaiKhuyenMai, @NgayBatDau, @NgayKetThuc)

    RETURN SCOPE_IDENTITY()
END
GO

CREATE OR ALTER FUNCTION KiemTraTheoLoaiKhuyenMai
(
    @LoaiKhuyenMai NVARCHAR(10),
    @MaSanPham INT,
    @GiaTriKhuyenMai FLOAT,
    @MaSanPham2 INT = NULL,
    @LoaiKhachHang NVARCHAR(20) = NULL
)
RETURNS BIT
AS
BEGIN
    -- Kiểm tra sản phẩm tồn tại
    IF NOT EXISTS (SELECT 1 FROM SAN_PHAM WHERE MaSanPham = @MaSanPham AND DaXoa = 0)
        RETURN 0

    -- Kiểm tra sản phẩm thứ hai (nếu loại khuyến mãi là Combo)
    IF @LoaiKhuyenMai = 'Combo'
    BEGIN
        IF @MaSanPham2 IS NULL
            RETURN 0
        IF @MaSanPham2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM SAN_PHAM WHERE MaSanPham = @MaSanPham2 AND DaXoa = 0)
            RETURN 0
    END
     
    -- Kiểm tra loại khách hàng (nếu loại khuyến mãi là Member)
    IF @LoaiKhuyenMai = 'Member'
    BEGIN
        IF @LoaiKhachHang IS NULL
            RETURN 0
        IF @LoaiKhachHang IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PHAN_LOAI WHERE Loai = @LoaiKhachHang)
            RETURN 0
    END

    -- Kiểm tra giá trị khuyến mãi hợp lệ
    IF @GiaTriKhuyenMai < 0 OR @GiaTriKhuyenMai > 100
        RETURN 0
    IF @LoaiKhuyenMai = 'Flash' AND @GiaTriKhuyenMai > 50
        RETURN 0
    IF @LoaiKhuyenMai = 'Combo' AND @GiaTriKhuyenMai > 30
        RETURN 0
    IF @LoaiKhuyenMai = 'Member'
    BEGIN
        IF @LoaiKhachHang = N'Kim cương' AND @GiaTriKhuyenMai > 15
            RETURN 0
        IF @LoaiKhachHang = N'Bạch kim' AND @GiaTriKhuyenMai > 12
            RETURN 0
        IF @LoaiKhachHang = N'Vàng' AND @GiaTriKhuyenMai > 10
            RETURN 0
        IF @LoaiKhachHang = N'Bạc' AND @GiaTriKhuyenMai > 8
            RETURN 0
        IF @LoaiKhachHang = N'Đồng' AND @GiaTriKhuyenMai > 5
            RETURN 0
    END

    RETURN 1
END
GO
