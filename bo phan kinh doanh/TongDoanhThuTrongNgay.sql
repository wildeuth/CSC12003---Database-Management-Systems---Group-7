-- Thủ tục tính tổng doanh thu hàng ngày
CREATE OR ALTER PROCEDURE sp_TinhTongDoanhThuHangNgay
    @Ngay DATETIME,
	 @TongDThu  DECIMAL(18, 2) OUTPUT
AS
BEGIN

    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
/*
	CREATE TABLE #DanhSachHoaDon (
        MaHoaDon INT,
        TongTien DECIMAL(18, 2)
    );

    -- Gọi procedure để lấy danh sách hoá đơn trong ngày
    INSERT INTO #DanhSachHoaDon (MaHoaDon, TongTien)
    EXEC sp_LayDanhSachHoaDonTrongNgay @Ngay;

    -- Khởi tạo biến tổng doanh thu
    DECLARE @Tong MONEY = 0;
    DECLARE @CurrentTongTien MONEY

    -- Con trỏ để lặp qua từng hoá đơn trong danh sách
    DECLARE HoaDon_Cursor CURSOR FOR
    SELECT TongTien FROM #DanhSachHoaDon;
    -- Mở con trỏ
    OPEN HoaDon_Cursor;
    -- Lấy dòng đầu tiên
    FETCH NEXT FROM HoaDon_Cursor INTO @CurrentTongTien;
    -- Vòng lặp tính tổng doanh thu
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Tong = @Tong + @CurrentTongTien;
        -- Lấy dòng tiếp theo
        FETCH NEXT FROM HoaDon_Cursor INTO @CurrentTongTien;
    END;
    -- Đóng và giải phóng con trỏ
    CLOSE HoaDon_Cursor;
    DEALLOCATE HoaDon_Cursor;
    -- Trả kết quả tổng doanh thu
    SET @TongDThu = @Tong;
    -- Xoá bảng tạm
    DROP TABLE #DanhSachHoaDon;
	*/

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

		-- Drop temporary table
		DROP TABLE #DanhSachHoaDon;

    -- Return result
		PRINT 'Total revenue of '+  CAST(@Ngay AS NVARCHAR(20))+' is ' + CAST(@TongDThu AS NVARCHAR(50));

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END

DECLARE @TongDThu DECIMAL(18,2);

EXEC sp_TinhTongDoanhThuHangNgay @Ngay = '2024-11-01 14:00:00.000', @TongDThu = @TongDThu OUTPUT;


-- Thủ tục lấy danh sách hoá đơn trong ngày
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
		WHERE PMS.NgayDat = @Ngay;

		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END

--Vì nó đã lock luôn rồi nên lúc insert dô là ko cập nhật được => ko lấy ra được những hóa đơn sau khi đã dùng sp này
exec sp_LayDanhSachHoaDonTrongNgay @Ngay = '2024-11-01 14:00:00.000'

