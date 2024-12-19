USE QLST
GO

-- Thêm danh mục sản phẩm
CREATE OR ALTER PROCEDURE ThemDanhMucSanPham
    @TenDanhMuc NVARCHAR(100)
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập (Read Committed để tránh Dirty Read)
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra tên danh mục đã tồn tại
        IF EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK) -- Khóa để ngăn các giao dịch khác thay đổi hoặc thêm dữ liệu trùng
            WHERE TenDanhMuc = @TenDanhMuc AND DaXoa = 0
        )
            THROW 50000, 'Tên danh mục đã được sử dụng.', 1

        -- Thêm danh mục mới
        INSERT INTO DANH_MUC (TenDanhMuc)
        VALUES (@TenDanhMuc)

        PRINT N'Thêm danh mục thành công.'

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO

-- Cập nhật danh mục sản phẩm
CREATE OR ALTER PROCEDURE CapNhatDanhMucSanPham
    @MaDanhMuc INT,
    @TenDanhMuc NVARCHAR(100)
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra danh mục tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK) -- Ngăn các giao dịch khác xóa hoặc thay đổi bản ghi
            WHERE MaDanhMuc = @MaDanhMuc AND DaXoa = 0
        )
            THROW 50000, 'Danh mục không tồn tại.', 1

        -- Kiểm tra tên danh mục đã tồn tại
        IF EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK) -- Ngăn thêm bản ghi trùng
            WHERE TenDanhMuc = @TenDanhMuc AND DaXoa = 0
        )
            THROW 50000, 'Tên danh mục đã được sử dụng.', 1

        -- Cập nhật danh mục
        UPDATE DANH_MUC
        SET TenDanhMuc = @TenDanhMuc
        WHERE MaDanhMuc = @MaDanhMuc

        PRINT N'Cập nhật danh mục thành công.'

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO

-- Xóa danh mục sản phẩm
CREATE OR ALTER PROCEDURE XoaDanhMucSanPham
    @MaDanhMuc INT
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        -- Kiểm tra danh mục tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK) -- Ngăn các giao dịch khác xóa cùng lúc
            WHERE MaDanhMuc = @MaDanhMuc AND DaXoa = 0
        )
            THROW 50000, 'Danh mục không tồn tại.', 1

        -- Đánh dấu đã xóa sản phẩm
        UPDATE SAN_PHAM
        SET DaXoa = 1
        WHERE MaDanhMuc = @MaDanhMuc

        -- Đánh dấu đã xóa danh mục
        UPDATE DANH_MUC
        SET DaXoa = 1
        WHERE MaDanhMuc = @MaDanhMuc

        PRINT N'Xóa danh mục thành công.'

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO
