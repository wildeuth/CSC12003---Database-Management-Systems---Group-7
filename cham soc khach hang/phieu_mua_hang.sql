USE QLST
GO

-- Tặng phiếu mua hàng sinh nhật
CREATE OR ALTER PROCEDURE TangPhieuMuaHangSinhNhat
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Biến để lưu tháng hiện tại
        DECLARE @ThangHienTai INT = MONTH(GETDATE()), @NamHienTai INT = YEAR(GETDATE())

        -- Lấy danh sách khách hàng có ngày sinh nhật trong tháng hiện tại
        DECLARE @DanhSachKhachHang TABLE (
            MaKhachHang INT,
            LoaiKhachHang NVARCHAR(20),
            GiaTri MONEY
        )

        -- Thiết lập mức cô lập (Read Committed) để tránh đọc dữ liệu chưa commit
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Chèn khách hàng có sinh nhật vào bảng tạm
        INSERT INTO @DanhSachKhachHang (MaKhachHang, LoaiKhachHang, GiaTri)
        SELECT 
            KH.MaKhachHang,
            KH.LoaiKhachHang,
            PL.GiaTri
        FROM KHACH_HANG KH
        INNER JOIN PHAN_LOAI PL ON KH.LoaiKhachHang = PL.Loai
        WHERE MONTH(KH.NgaySinh) = @ThangHienTai

        -- Kiểm tra danh sách khách hàng có tồn tại không
        IF NOT EXISTS (SELECT 1 FROM @DanhSachKhachHang)
        BEGIN
            PRINT N'Không có khách hàng nào sinh nhật trong tháng này.'
            RETURN
        END

        -- Kiểm tra nếu đã tặng phiếu mua hàng trong tháng này
        IF EXISTS (SELECT 1 FROM PHIEU_MUA_HANG WHERE MONTH(NgayTao) = @ThangHienTai AND YEAR(NgayTao) = @NamHienTai)
        BEGIN
            PRINT N'Tháng này đã tặng phiếu mua hàng.'
            RETURN
        END

        -- Duyệt danh sách khách hàng và tạo phiếu mua hàng
        DECLARE @MaKhachHang INT
        DECLARE @GiaTri MONEY

        DECLARE KhachHangCursor CURSOR FOR
        SELECT MaKhachHang, GiaTri FROM @DanhSachKhachHang

        OPEN KhachHangCursor
        FETCH NEXT FROM KhachHangCursor INTO @MaKhachHang, @GiaTri

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Tạo phiếu mua hàng cho khách hàng
            INSERT INTO PHIEU_MUA_HANG (MaKhachHang, GiaTri, NgayTao, DaDung)
            VALUES (@MaKhachHang, @GiaTri, GETDATE(), 0)
            
            -- Gửi thông báo cho khách hàng
            INSERT INTO THONG_BAO (MaKhachHang, NoiDung)
            VALUES (@MaKhachHang, N'Siêu thị gửi tặng phiếu mua hàng cho bạn nhân ngày sinh nhật')

            FETCH NEXT FROM KhachHangCursor INTO @MaKhachHang, @GiaTri
        END

        CLOSE KhachHangCursor
        DEALLOCATE KhachHangCursor

        COMMIT TRAN
        PRINT N'Tặng phiếu mua hàng thành công cho tất cả khách hàng có sinh nhật trong tháng.'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO
