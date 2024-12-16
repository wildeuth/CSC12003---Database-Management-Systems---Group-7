

-- Thủ tục tính tổng doanh thu hàng ngày
CREATE OR ALTER PROCEDURE sp_TinhTongDoanhThuHangNgay
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TongDThu MONEY = 0;

    -- Lấy danh sách hoá đơn trong ngày
    DECLARE @DanhSachHoaDon TABLE (
        MaHoaDon INT,
        TongTien MONEY
    );

    INSERT INTO @DanhSachHoaDon (MaHoaDon, TongTien)
    EXEC sp_LayDanhSachHoaDonTrongNgay @Ngay;

    -- Tính tổng doanh thu
    SELECT @TongDThu = SUM(TongTien) FROM @DanhSachHoaDon;

    PRINT N'Tổng doanh thu trong ngày: ' + CAST(@TongDThu AS NVARCHAR(20));
    RETURN @TongDThu;
END
GO

-- Thủ tục lấy danh sách hoá đơn trong ngày
CREATE OR ALTER PROCEDURE sp_LayDanhSachHoaDonTrongNgay
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT HD.MaHoaDon, HD.TongTien
    FROM PHIEU_MUA_SAM PMS
    INNER JOIN HOA_DON HD ON PMS.MaPhieu = HD.MaPhieu
    WHERE PMS.NgayDat = @Ngay;
END
GO

-- Thủ tục lấy danh sách sản phẩm đã bán kèm số lượng
