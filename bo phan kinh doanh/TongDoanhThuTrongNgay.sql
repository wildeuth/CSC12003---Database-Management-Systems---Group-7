-- Thủ tục tính tổng doanh thu hàng ngày
CREATE OR ALTER PROCEDURE sp_TinhTongDoanhThuHangNgay
    @Ngay DATETIME,
	 @TongDThu  DECIMAL(18, 2) OUTPUT
AS
BEGIN

    SET NOCOUNT ON;
	 -- Initialize total revenue
    SET @TongDThu = 0;

    CREATE TABLE #DanhSachHoaDon (
        MaHoaDon INT,
        TongTien DECIMAL(18, 2)
    );

    INSERT INTO #DanhSachHoaDon
    EXEC sp_LayDanhSachHoaDonTrongNgay @Ngay;

    -- Calculate total revenue
    SELECT @TongDThu = SUM(TongTien)
    FROM #DanhSachHoaDon;

    -- Drop temporary table
    DROP TABLE #DanhSachHoaDon;

    -- Return result
    PRINT 'Total revenue of '+  CAST(@Ngay AS NVARCHAR(20))+' is ' + CAST(@TongDThu AS NVARCHAR(50));

END
GO
DECLARE @TongDThu DECIMAL(18, 2);

EXEC sp_TinhTongDoanhThuHangNgay @Ngay = '2024-11-01 14:00:00.000', @TongDThu = @TongDThu OUTPUT;


-- Thủ tục lấy danh sách hoá đơn trong ngày
CREATE OR ALTER PROCEDURE sp_LayDanhSachHoaDonTrongNgay
    @Ngay DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	-- Lấy danh sách phiếu mua sắm có ngày đặt = @Ngay
	 -- Lấy danh sách hóa đơn trong ngày
    SELECT HD.MaHoaDon,hd.TongTien
    FROM HOA_DON AS HD WITH (READCOMMITTED, ROWLOCK)
    JOIN PHIEU_MUA_SAM AS PMS WITH (READCOMMITTED, ROWLOCK)
        ON HD.MaPhieuMuaSam = PMS.MaPhieuMuaSam
    WHERE PMS.NgayDat = @Ngay;

END
GO

exec sp_LayDanhSachHoaDonTrongNgay @Ngay = '2024-11-01 14:00:00.000'

