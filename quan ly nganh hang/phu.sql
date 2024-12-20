USE QLST
GO

-- Stored Procedure: Tạo Mã Khuyến Mãi
CREATE OR ALTER PROCEDURE TaoMaKhuyenMai
    @TenKhuyenMai NVARCHAR(200),
    @LoaiKhuyenMai NVARCHAR(10),
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra loại khuyến mãi hợp lệ
        IF @LoaiKhuyenMai NOT IN ('Flash', 'Combo', 'Member')
            THROW 50000, 'Loại khuyến mãi không hợp lệ.', 1

        -- Kiểm tra ngày kết thúc >= ngày bắt đầu
        IF @NgayKetThuc < @NgayBatDau
            THROW 50000, 'Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.', 1

        -- Thêm khuyến mãi mới và lấy ID
        INSERT INTO KHUYEN_MAI (TenKhuyenMai, LoaiKhuyenMai, NgayBatDau, NgayKetThuc)
        VALUES (@TenKhuyenMai, @LoaiKhuyenMai, @NgayBatDau, @NgayKetThuc)

        -- Trả về ID mới tạo
        DECLARE @NewId INT = SCOPE_IDENTITY()

        COMMIT TRAN
        RETURN @NewId
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO

-- User Defined Function: Kiểm Tra Theo Loại Khuyến Mãi
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
    -- Thiết lập mức cô lập Read Committed để tránh đọc dữ liệu chưa commit
    DECLARE @Result BIT = 1

    -- Kiểm tra sản phẩm tồn tại
    IF NOT EXISTS (SELECT 1 FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK) WHERE MaSanPham = @MaSanPham AND DaXoa = 0)
    BEGIN
        SET @Result = 0
        RETURN @Result
    END

    -- Kiểm tra sản phẩm thứ hai (nếu loại khuyến mãi là Combo)
    IF @LoaiKhuyenMai = 'Combo'
    BEGIN
        IF @MaSanPham2 IS NULL OR NOT EXISTS (SELECT 1 FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK) WHERE MaSanPham = @MaSanPham2 AND DaXoa = 0)
        BEGIN
            SET @Result = 0
            RETURN @Result
        END
    END

    -- Kiểm tra loại khách hàng (nếu loại khuyến mãi là Member)
    IF @LoaiKhuyenMai = 'Member'
    BEGIN
        IF @LoaiKhachHang IS NULL OR NOT EXISTS (SELECT 1 FROM PHAN_LOAI WITH (UPDLOCK, HOLDLOCK) WHERE Loai = @LoaiKhachHang)
        BEGIN
            SET @Result = 0
            RETURN @Result
        END
    END

    -- Kiểm tra giá trị khuyến mãi hợp lệ
    IF @GiaTriKhuyenMai < 0 OR @GiaTriKhuyenMai > 100
        SET @Result = 0
    IF @LoaiKhuyenMai = 'Flash' AND @GiaTriKhuyenMai > 50
        SET @Result = 0
    IF @LoaiKhuyenMai = 'Combo' AND @GiaTriKhuyenMai > 30
        SET @Result = 0
    IF @LoaiKhuyenMai = 'Member'
    BEGIN
        IF (@LoaiKhachHang = N'Kim cương' AND @GiaTriKhuyenMai > 15) OR
           (@LoaiKhachHang = N'Bạch kim' AND @GiaTriKhuyenMai > 12) OR
           (@LoaiKhachHang = N'Vàng' AND @GiaTriKhuyenMai > 10) OR
           (@LoaiKhachHang = N'Bạc' AND @GiaTriKhuyenMai > 8) OR
           (@LoaiKhachHang = N'Đồng' AND @GiaTriKhuyenMai > 5)
        BEGIN
            SET @Result = 0
        END
    END

    RETURN @Result
END;
GO
