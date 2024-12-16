USE QLST
GO

-- Đăng ký khách hàng
CREATE OR ALTER PROCEDURE DangKyKhachHang
    @HoTen NVARCHAR(100),
    @Email NVARCHAR(100),
    @DiaChi NVARCHAR(200),
    @NgaySinh DATE,
    @SoDienThoai NVARCHAR(20),
    @LoaiKhachHang NVARCHAR(20) = N'Thân thiết'
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra số điện thoại đã tồn tại
        IF EXISTS (SELECT 1 FROM KHACH_HANG WITH (UPDLOCK, HOLDLOCK) WHERE SoDienThoai = @SoDienThoai)
            THROW 50000, 'Số điện thoại đã được sử dụng.', 1

        -- Kiểm tra email đã tồn tại
        IF EXISTS (SELECT 1 FROM KHACH_HANG WITH (UPDLOCK, HOLDLOCK) WHERE Email = @Email)
            THROW 50000, 'Email đã được sử dụng.', 1

        -- Kiểm tra loại khách hàng tồn tại trong bảng PHAN_LOAI
        IF NOT EXISTS (SELECT 1 FROM PHAN_LOAI WHERE Loai = @LoaiKhachHang)
            THROW 50000, 'Loại khách hàng không hợp lệ.', 1

        -- Thêm khách hàng
        INSERT INTO KHACH_HANG (HoTen, Email, DiaChi, NgaySinh, SoDienThoai, LoaiKhachHang)
        VALUES (@HoTen, @Email, @DiaChi, @NgaySinh, @SoDienThoai, @LoaiKhachHang)

        COMMIT TRAN
        PRINT N'Đăng ký khách hàng thành công.'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO


-- Cập nhật thông tin khách hàng
CREATE OR ALTER PROCEDURE CapNhatThongTinKhachHang
    @MaKhachHang INT,
    @HoTen NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @DiaChi NVARCHAR(200) = NULL,
    @NgaySinh DATE = NULL,
    @SoDienThoai NVARCHAR(20) = NULL,
    @LoaiKhachHang NVARCHAR(20) = NULL,
    @TienTichLuy MONEY = NULL
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Repeatable Read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra mã khách hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM KHACH_HANG WHERE MaKhachHang = @MaKhachHang)
            THROW 50000, 'Mã khách hàng không tồn tại.', 1

        -- Kiểm tra số điện thoại đã tồn tại với khách hàng khác
        IF @SoDienThoai IS NOT NULL AND EXISTS (
            SELECT 1 FROM KHACH_HANG 
            WHERE SoDienThoai = @SoDienThoai AND MaKhachHang <> @MaKhachHang
        )
            THROW 50000, 'Số điện thoại đã được sử dụng.', 1

        -- Kiểm tra email đã tồn tại với khách hàng khác
        IF @Email IS NOT NULL AND EXISTS (
            SELECT 1 FROM KHACH_HANG 
            WHERE Email = @Email AND MaKhachHang <> @MaKhachHang
        )
            THROW 50000, 'Email đã được sử dụng.', 1

        -- Kiểm tra loại khách hàng tồn tại
        IF @LoaiKhachHang IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PHAN_LOAI WHERE Loai = @LoaiKhachHang)
            THROW 50000, 'Loại khách hàng không hợp lệ.', 1

        -- Cập nhật thông tin khách hàng
        UPDATE KHACH_HANG
        SET 
            HoTen = COALESCE(@HoTen, HoTen),
            Email = COALESCE(@Email, Email),
            DiaChi = COALESCE(@DiaChi, DiaChi),
            NgaySinh = COALESCE(@NgaySinh, NgaySinh),
            SoDienThoai = COALESCE(@SoDienThoai, SoDienThoai),
            LoaiKhachHang = COALESCE(@LoaiKhachHang, LoaiKhachHang),
            TienTichLuy = COALESCE(@TienTichLuy, TienTichLuy)
        WHERE MaKhachHang = @MaKhachHang

        COMMIT TRAN
        PRINT N'Cập nhật thông tin khách hàng thành công.'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO


-- Cập nhật hạng khách hàng hàng tháng
CREATE OR ALTER PROCEDURE CapNhatHangKhachHangHangThang
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Serializable
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        -- Tìm kiếm khách hàng cần cập nhật (NgayDangKy >= 365 ngày trước)
        DECLARE @KhachHangCursor CURSOR
        SET @KhachHangCursor = CURSOR FOR
        SELECT MaKhachHang, TienTichLuy
        FROM KHACH_HANG
        WHERE DATEDIFF(DAY, NgayDangKy, GETDATE()) >= 365

        OPEN @KhachHangCursor

        DECLARE @MaKhachHang INT
        DECLARE @TienTichLuy MONEY
        DECLARE @LoaiKhachHang NVARCHAR(20)

        FETCH NEXT FROM @KhachHangCursor INTO @MaKhachHang, @TienTichLuy

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Xác định phân hạng mới từ bảng PHAN_LOAI
            SELECT TOP 1 @LoaiKhachHang = Loai
            FROM PHAN_LOAI
            WHERE @TienTichLuy >= DieuKien
            ORDER BY DieuKien DESC

            -- Cập nhật hạng khách hàng, đặt lại tiền tích lũy, và cập nhật ngày đăng ký
            UPDATE KHACH_HANG
            SET 
                LoaiKhachHang = @LoaiKhachHang,
                TienTichLuy = 0,
                NgayDangKy = GETDATE()
            WHERE MaKhachHang = @MaKhachHang

            FETCH NEXT FROM @KhachHangCursor INTO @MaKhachHang, @TienTichLuy
        END

        CLOSE @KhachHangCursor
        DEALLOCATE @KhachHangCursor

        COMMIT TRAN
        PRINT N'Cập nhật hạng khách hàng thành công.'
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN;
        THROW; -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO
