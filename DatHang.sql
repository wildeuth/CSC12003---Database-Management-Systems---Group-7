USE QLST
GO

CREATE PROCEDURE KiemTraHangTonCuaSanPham
    @MaSanPham INT,
    @Ngay DATE,
    @QuyetDinh  INT OUT,
    @SoLuongDat  INT OUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    DECLARE @SoLuongTonKho INT, @SoLuongDaBan INT, @SLSPTD INT;

    -- Read current stock and sales data
    SELECT @SoLuongTonKho = SoLuongTonKhoHienTai, @SLSPTD = SLSPTD
    FROM SAN_PHAM WITH (HOLDLOCK)
    WHERE MaSanPham = @MaSanPham;

    SELECT @SoLuongDaBan = SUM(SoLuongDat)
    FROM CHI_TIET_PHIEU_MUA_SAM WITH (NOLOCK)
    WHERE MaSanPham = @MaSanPham AND MaPhieuMuaSam IN (
        SELECT MaPhieuMuaSam
        FROM PHIEU_MUA_SAM WITH (NOLOCK)
        WHERE CONVERT(DATE, NgayDat) = @Ngay
    );

    -- Check if order is needed
    IF (@SoLuongTonKho - @SoLuongDaBan < 0.7 * @SLSPTD)
    BEGIN
        SET @SoLuongDat = @SLSPTD - (@SoLuongTonKho - @SoLuongDaBan);
        SET @QuyetDinh = 1;
    END
    ELSE
    BEGIN
        SET @SoLuongDat = 0;
        SET @QuyetDinh = 0;
    END

    COMMIT TRANSACTION;
END
GO

-- Stored Procedure: DatHangSanPham
CREATE PROCEDURE DatHangSanPham
    @MaSanPham INT,
	@NgayDat DATE,
    @SoLuongDat INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    -- Exclusive lock for inserting into PHIEU_DAT_HANG
    INSERT INTO PHIEU_DAT_HANG (MaSanPham, SoLuongDat, NgayDat, DaNhanHang)
    VALUES (@MaSanPham, @SoLuongDat, @NgayDat, 0);

    COMMIT TRANSACTION;
END
GO
-- Stored Procedure: KiemTraVaDatHang
CREATE PROCEDURE KiemTraVaDatHang
    @MaSanPham INT,
	@NgayDat DaTE
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
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
