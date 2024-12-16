USE QLST
GO

-- proc dư thừa không cần
-- Tạo phiếu mua hàng
CREATE OR ALTER PROCEDURE TaoPhieuMuaHang
    @MaKhachHang INT
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra khách hàng có tồn tại
        IF NOT EXISTS (SELECT 1 FROM KHACH_HANG WITH (UPDLOCK, HOLDLOCK) WHERE MaKhachHang = @MaKhachHang)
            THROW 50000, 'Khách hàng không tồn tại.', 1

        -- Lấy loại khách hàng và giá trị từ phân loại
        DECLARE @LoaiKhachHang NVARCHAR(20)
        DECLARE @GiaTri MONEY

        SELECT 
            @LoaiKhachHang = LoaiKhachHang
        FROM KHACH_HANG
        WHERE MaKhachHang = @MaKhachHang

        -- Lấy giá trị tương ứng từ PHAN_LOAI
        SELECT 
            @GiaTri = GiaTri
        FROM PHAN_LOAI
        WHERE Loai = @LoaiKhachHang

        -- Kiểm tra giá trị hợp lệ
        IF @GiaTri IS NULL OR @GiaTri <= 0
            THROW 50000, 'Giá trị phiếu mua hàng không hợp lệ.', 1

        -- Tạo phiếu mua hàng
        INSERT INTO PHIEU_MUA_HANG (MaKhachHang, GiaTri, NgayTao, DaDung)
        VALUES (@MaKhachHang, @GiaTri, GETDATE(), 0)

        COMMIT TRAN
        PRINT N'Tạo phiếu mua hàng thành công cho khách hàng có Mã: ' + CAST(@MaKhachHang AS NVARCHAR)
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO


-- proc dư thừa không cần
-- Tạo thông báo
CREATE OR ALTER PROCEDURE TaoThongBao
    @MaKhachHang INT,
    @NoiDung NVARCHAR(255)
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra nếu khách hàng có tồn tại
        IF NOT EXISTS (SELECT 1 FROM KHACH_HANG WITH (UPDLOCK, HOLDLOCK) WHERE MaKhachHang = @MaKhachHang)
            THROW 50000, 'Khách hàng không tồn tại.', 1

        -- Kiểm tra nội dung thông báo
        IF @NoiDung IS NULL OR LEN(@NoiDung) = 0
            THROW 50000, 'Nội dung thông báo không được để trống.', 1

        -- Tạo thông báo
        INSERT INTO THONG_BAO (MaKhachHang, NoiDung)
        VALUES (@MaKhachHang, @NoiDung)

        COMMIT TRAN
        PRINT N'Tạo thông báo thành công cho khách hàng có Mã: ' + CAST(@MaKhachHang AS NVARCHAR)
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO
