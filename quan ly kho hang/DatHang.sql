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

    DECLARE @SoLuongMua INT, @SoLuongTon INT, @SLSPTD INT, @SoLuongConLai INT;

    -- Lấy thông tin tồn kho và sản phẩm tối đa
    SELECT @SoLuongTon = SoLuongTonKhoHienTai, @SLSPTD = SoLuongSanPhamToiDa
    FROM SAN_PHAM WITH (HOLDLOCK)
    WHERE MaSanPham = @MaSanPham;

    -- Cursor để duyệt qua các ngày và đơn hàng
    DECLARE OrderCursor CURSOR FOR
    SELECT SUM(SoLuong) AS SoLuongMua
    FROM ChiTietPhieuMuaSam c
    JOIN PhieuMuaSam p ON c.MaPhieuMuaSam = p.MaPhieuMuaSam
    WHERE p.MaSanPham = @MaSanPham AND p.Ngay <= @Ngay
    GROUP BY p.Ngay
    ORDER BY p.Ngay DESC;

    OPEN OrderCursor;

    -- Duyệt qua từng đơn hàng
    FETCH NEXT FROM OrderCursor INTO @SoLuongMua;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính toán số lượng còn lại
        SET @SoLuongConLai = @SoLuongTon - @SoLuongMua;

        -- Kiểm tra điều kiện đặt hàng
        IF @SoLuongConLai < 0.7 * @SLSPTD
        BEGIN
            SET @QuyetDinhDatHang = 1;
            SET @SoLuongDat = @SLSPTD - @SoLuongConLai;
            BREAK; -- Dừng vòng lặp nếu thỏa mãn điều kiện
        END

        -- Lặp qua đơn hàng tiếp theo
        FETCH NEXT FROM OrderCursor INTO @SoLuongMua;
    END

    -- Nếu không có điều kiện nào thỏa mãn
    IF @@FETCH_STATUS <> 0
    BEGIN
        SET @QuyetDinhDatHang = 0;
        SET @SoLuongDat = 0;
    END

    CLOSE OrderCursor;
    DEALLOCATE OrderCursor;

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
