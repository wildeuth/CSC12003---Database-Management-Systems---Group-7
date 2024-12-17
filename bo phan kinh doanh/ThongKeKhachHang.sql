-- Thủ tục thống kê số lượng khách hàng mua sản phẩm trong ngày
CREATE OR ALTER PROCEDURE sp_ThongKeKhachHangHangNgay
    @Ngay DATETIME,
	@Tong INT output
AS
BEGIN
    SET NOCOUNT ON;

	
    -- Bước 1: Lấy số lượng khách hàng của từng sản phẩm
    Create table #TableSoLuongKhachHang (MaSanPham INT, SoLuongKhachHang INT);
    INSERT INTO #TableSoLuongKhachHang (MaSanPham, SoLuongKhachHang)
    EXEC sp_LaySoLuongKhachHangMuaSanPham @Ngay;

    -- Bước 2: Tính tổng số lượng khách hàng
    SELECT @Tong = SUM(SoLuongKhachHang)
    FROM #TableSoLuongKhachHang;

    -- Bước 3: Trả kết quả
    SELECT @Tong AS TongSoLuongKhachHang;

	drop table #TableSoLuongKhachHang
END
GO

DECLARE @TongKhachHang INT;
EXEC sp_ThongKeKhachHangHangNgay @Ngay =  '2024-11-01 14:00:00.000', @Tong = @TongKhachHang OUTPUT;

PRINT 'Tổng số lượng khách hàng: ' + CAST(@TongKhachHang AS NVARCHAR);


-- Lấy số lượng khách hàng đã mua sản phẩm
CREATE or alter PROCEDURE sp_LaySoLuongKhachHangMuaSanPham
    @Ngay DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #DanhSachSanPham (MaSanPham INT);

    -- Lấy danh sách sản phẩm đã bán
    INSERT INTO #DanhSachSanPham (MaSanPham)
    SELECT DISTINCT CTHD.MaSanPham
    FROM CHI_TIET_HOA_DON AS CTHD WITH (READCOMMITTED, ROWLOCK)
    INNER JOIN HOA_DON AS HD
        ON CTHD.MaHoaDon = HD.MaHoaDon
    INNER JOIN PHIEU_MUA_SAM AS PMS
        ON HD.MaPhieuMuaSam = PMS.MaPhieuMuaSam
    WHERE PMS.NgayDat = @Ngay;

    -- Đếm số lượng khách hàng của từng sản phẩm
    SELECT SP.MaSanPham, COUNT(DISTINCT PMS.MaKhachHang) AS SoLuongKhachHang
    FROM PHIEU_MUA_SAM AS PMS WITH (READCOMMITTED, ROWLOCK)
    INNER JOIN CHI_TIET_PHIEU_MUA_SAM AS CTPMS WITH (READCOMMITTED, ROWLOCK)
        ON PMS.MaPhieuMuaSam = CTPMS.MaPhieuMuaSam
    INNER JOIN #DanhSachSanPham AS SP
        ON CTPMS.MaSanPham = SP.MaSanPham
    GROUP BY SP.MaSanPham;

    DROP TABLE #DanhSachSanPham;

END;

exec sp_LaySoLuongKhachHangMuaSanPham @Ngay = '2024-11-01 14:00:00.000'

--Thủ tục: Lấy danh sách sản pham đã bán trong ngày: sp_LayDanhSachSanPhamDaBan
CREATE OR ALTER PROCEDURE sp_LayDanhSachSanPhamDaBan
    @Ngay DATETIME
AS
BEGIN
	set nocount on;

    -- Bảng tạm chứa danh sách hóa đơn
    CREATE TABLE #DanhSachHoaDon (MaHoaDon INT);

    -- Lấy danh sách hóa đơn trong ngày
    INSERT INTO #DanhSachHoaDon (MaHoaDon)
    EXEC sp_LayDanhSachHoaDonTrongNgay @Ngay;
    -- Bước 1: Lấy danh sách hóa đơn trong ngày
    --DECLARE @TableHoaDon TABLE (MaHoaDon INT);
    --INSERT INTO @TableHoaDon (MaHoaDon)
    select *from #DanhSachHoaDon

    -- Bước 2: Lấy chi tiết hóa đơn để xác định số lượng sản phẩm đã bán
    SELECT CTHD.MaSanPham, SUM(CTHD.SoLuong) AS SoLuong
    FROM CHI_TIET_HOA_DON CTHD WITH (READCOMMITTED, ROWLOCK) -- Share Lock khi đọc chi tiết hóa đơn
    INNER JOIN #DanhSachHoaDon HD
        ON CTHD.MaHoaDon = HD.MaHoaDon
    GROUP BY CTHD.MaSanPham;

	drop table #DanhSachHoaDon
END
GO

exec sp_LayDanhSachSanPhamDaBan '2024-11-01 14:00:00.000'
