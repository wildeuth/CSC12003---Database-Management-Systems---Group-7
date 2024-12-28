use QLST
GO
-- Thủ tục lấy danh sách hoá đơn trong ngày
go
CREATE OR ALTER PROCEDURE sp_LayDanhSachHoaDonTrongNgay
    @Ngay DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	BEGIN TRANSACTION;
    BEGIN TRY
		-- Lấy danh sách phiếu mua sắm có ngày đặt = @Ngay
		 -- Lấy danh sách hóa đơn trong ngày
		SELECT HD.MaHoaDon,hd.TongTien
		FROM HOA_DON AS HD WITH (READCOMMITTED, ROWLOCK)
		JOIN PHIEU_MUA_SAM AS PMS WITH (READCOMMITTED, ROWLOCK)
			ON HD.MaPhieuMuaSam = PMS.MaPhieuMuaSam
		WHERE HD.ngayLap = @Ngay;

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END
go
--Vì nó đã lock luôn rồi nên lúc insert dô là ko cập nhật được => ko lấy ra được những hóa đơn sau khi đã dùng sp này
exec sp_LayDanhSachHoaDonTrongNgay @Ngay = '2024-12-29 00:00:00.000'

go
CREATE OR ALTER PROCEDURE sp_TinhTongDoanhThuHangNgay
    @Ngay DATETIME,
	 @TongDThu  DECIMAL(18, 2) OUTPUT
AS
BEGIN

    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	 -- Initialize total revenue
	BEGIN TRANSACTION;
    BEGIN TRY
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
		-- Return result
		select @TongDThu as TONGDOANHTHU
		-- Drop temporary table
		DROP TABLE #DanhSachHoaDon;

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END
go
DECLARE @TongDThu DECIMAL(18,2);

EXEC sp_TinhTongDoanhThuHangNgay @Ngay = '2024-12-29 00:00:00.000', @TongDThu = @TongDThu OUTPUT;


