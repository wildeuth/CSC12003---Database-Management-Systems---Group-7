USE QLST
GO

CREATE PROCEDURE KiemTraHangTonCuaSanPham
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
    SELECT @SoLuongMua = SUM(SoLuong)
    FROM ChiTietPhieuMuaSam c
    JOIN PhieuMuaSam p ON c.MaPhieuMuaSam = p.MaPhieuMuaSam
    WHERE p.MaSanPham = @MaSanPham AND p.Ngay = @Ngay;

    -- Lấy số lượng sản phẩm tối đa
    SELECT @SLSPTD = SoLuongSanPhamToiDa, @SoLuongTon = SoLuongTonKhoHienTai
    FROM SAN_PHAM WITH (HOLDLOCK)
    WHERE MaSanPham = @MaSanPham;

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
CREATE PROCEDURE DatHangSanPham
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
CREATE PROCEDURE KiemTraVaDatHang
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
