USE QLST
GO

-- Thêm nhà sản xuất
CREATE OR ALTER PROCEDURE ThemNhaSanXuat
    @TenNhaSanXuat NVARCHAR(50)
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra tên nhà sản xuất đã tồn tại
        IF EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK) -- Khóa tránh thêm trùng
            WHERE TenNhaSanXuat = @TenNhaSanXuat AND DaXoa = 0
        )
            THROW 50000, 'Tên nhà sản xuất đã được sử dụng.', 1

        -- Thêm nhà sản xuất mới
        INSERT INTO NHA_SAN_XUAT (TenNhaSanXuat)
        VALUES (@TenNhaSanXuat)

        PRINT N'Thêm nhà sản xuất thành công.'
        
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO


-- Cập nhật nhà sản xuất
CREATE OR ALTER PROCEDURE CapNhatNhaSanXuat
    @MaNhaSanXuat INT,
    @TenNhaSanXuat NVARCHAR(50)
AS
BEGIN
    BEGIN TRAN;
    BEGIN TRY
        -- Thiết lập mức cô lập Repeatable Read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra nhà sản xuất tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK) -- Ngăn thay đổi trong khi kiểm tra
            WHERE MaNhaSanXuat = @MaNhaSanXuat AND DaXoa = 0
        )
            THROW 50000, 'Nhà sản xuất không tồn tại.', 1

        -- Kiểm tra tên nhà sản xuất đã tồn tại
        IF EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK) -- Ngăn thêm tên trùng
            WHERE TenNhaSanXuat = @TenNhaSanXuat AND DaXoa = 0
        )
            THROW 50000, 'Tên nhà sản xuất đã được sử dụng.', 1

        -- Cập nhật nhà sản xuất
        UPDATE NHA_SAN_XUAT
        SET TenNhaSanXuat = @TenNhaSanXuat
        WHERE MaNhaSanXuat = @MaNhaSanXuat

        PRINT N'Cập nhật nhà sản xuất thành công.'
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Xóa nhà sản xuất
CREATE OR ALTER PROCEDURE XoaNhaSanXuat
    @MaNhaSanXuat INT
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Serializable
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        -- Kiểm tra nhà sản xuất tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK) -- Ngăn xóa đồng thời
            WHERE MaNhaSanXuat = @MaNhaSanXuat AND DaXoa = 0
        )
            THROW 50000, 'Nhà sản xuất không tồn tại.', 1

        -- Đánh dấu đã xóa các sản phẩm của nhà sản xuất
        UPDATE SAN_PHAM
        SET DaXoa = 1
        WHERE MaNhaSanXuat = @MaNhaSanXuat

        -- Đánh dấu nhà sản xuất là đã xóa
        UPDATE NHA_SAN_XUAT
        SET DaXoa = 1
        WHERE MaNhaSanXuat = @MaNhaSanXuat

        PRINT N'Xóa nhà sản xuất thành công.'
        
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO
