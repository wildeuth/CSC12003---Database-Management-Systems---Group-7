-- Thủ tục thống kê số lượng khách hàng mua sản phẩm trong ngày
CREATE OR ALTER PROCEDURE sp_ThongKeKhachHangHangNgay
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tong INT = 0;

    -- Lấy danh sách sản phẩm đã bán và số lượng khách hàng
    DECLARE @DanhSachSanPham TABLE (
        MaSanPham INT,
        SoLuongKhachHang INT
    );

    INSERT INTO @DanhSachSanPham (MaSanPham, SoLuongKhachHang)
    EXEC sp_LaySoLuongKhachHangMuaSanPham @Ngay;

    -- Tính tổng số lượng khách hàng mua sản phẩm
    SELECT @Tong = SUM(SoLuongKhachHang) FROM @DanhSachSanPham;

    PRINT N'Tổng số lượng khách hàng mua sản phẩm trong ngày: ' + CAST(@Tong AS NVARCHAR(10));
    RETURN @Tong;
END
GO


-- Thủ tục lấy số lượng khách hàng mua từng sản phẩm
CREATE OR ALTER PROCEDURE sp_LaySoLuongKhachHangMuaSanPham
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DanhSachSanPham TABLE (
        MaSanPham INT,
        SoLuongKhachHang INT
    );

    INSERT INTO @DanhSachSanPham (MaSanPham, SoLuongKhachHang)
    SELECT DISTINCT CT.MaSanPham, COUNT(DISTINCT PMS.MaKhachHang) AS SoLuongKhachHang
    FROM CHI_TIET_PHIEU_MUA_SAM CT
    INNER JOIN PHIEU_MUA_SAM PMS ON CT.MaPhieu = PMS.MaPhieu
    WHERE PMS.NgayDat = @Ngay
    GROUP BY CT.MaSanPham;

    SELECT * FROM @DanhSachSanPham;
END
GO



CREATE OR ALTER PROCEDURE sp_LayDanhSachSanPhamDaBan
    @Ngay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CT.MaSanPham, SUM(CT.SoLuong) AS SoLuong
    FROM HOA_DON HD
    INNER JOIN CHI_TIET_HOA_DON CT ON HD.MaHoaDon = CT.MaHoaDon
    WHERE HD.NgayLap = @Ngay
    GROUP BY CT.MaSanPham;
END
GO