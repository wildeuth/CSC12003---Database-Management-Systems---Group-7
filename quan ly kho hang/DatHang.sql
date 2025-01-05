USE QLST
GO

CREATE or alter PROCEDURE KiemTraHangTonCuaSanPham
    @MaSanPham INT,
    @Ngay DATE,
    @QuyetDinhDatHang BIT OUTPUT,
    @SoLuongDat INT OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION;

    DECLARE @SoLuongMua INT, @SLSPTD INT, @SoLuongTon INT, @SoLuongConLai INT;

    -- Tìm số lượng mua trong ngày
    SELECT @SoLuongMua = SUM(c.SoLuongDat)
    FROM CHI_TIET_PHIEU_MUA_SAM c
    JOIN PHIEU_MUA_SAM p ON c.MaPhieuMuaSam = p.MaPhieuMuaSam
    WHERE c.MaSanPham = @MaSanPham AND p.NgayDat = @Ngay;

    -- Lấy số lượng sản phẩm tối đa
    SELECT @SLSPTD = SLSPTD, @SoLuongTon = SoLuongTonKhoHienTai
    FROM SAN_PHAM 
    WHERE MaSanPham = @MaSanPham AND DaXoa = 0;

    -- Kiểm tra điều kiện đặt hàng
    SET @SoLuongConLai = @SoLuongTon - @SoLuongMua;

    IF @SoLuongConLai < 0.7 * @SLSPTD AND @SoLuongMua > 0.1 * @SLSPTD
    BEGIN
        SET @QuyetDinhDatHang = 1;
        SET @SoLuongDat = @SLSPTD - @SoLuongConLai;
    END
    ELSE
    BEGIN
        SET @QuyetDinhDatHang = 0;
        SET @SoLuongDat = 0;
    END

    COMMIT TRANSACTION;
END;
GO

-- Stored Procedure: DatHangSanPham
CREATE or alter PROCEDURE DatHangSanPham
    @MaSanPham INT,
	@NgayDat DATE,
    @SoLuongDat INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION;

    -- Exclusive lock for inserting into PHIEU_DAT_HANG
    INSERT INTO PHIEU_DAT_HANG (MaSanPham, SoLuongDat, NgayDat, DaNhanHang)
    VALUES (@MaSanPham, @SoLuongDat, @NgayDat, 0);

    COMMIT TRANSACTION;
END
GO
-- Stored Procedure: KiemTraVaDatHang
CREATE or ALTER PROCEDURE KiemTraVaDatHang
    @MaSanPham INT,
	@NgayDat DaTE
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION;

    DECLARE @QuyetDinh INT, @SoLuongDat INT;

    -- Call KiemTraHangTonCuaSanPham with OUTPUT parameters
    EXEC KiemTraHangTonCuaSanPham @MaSanPham, @NgayDat, @QuyetDinh OUT, @SoLuongDat OUT ;

    -- Decision making based on output
    IF @QuyetDinh = 1
    BEGIN
        EXEC DatHangSanPham @MaSanPham,@NgayDat, @SoLuongDat;
    END
    ELSE
    BEGIN
        PRINT 'No need to place an order';
    END

    COMMIT TRANSACTION;
END
GO
