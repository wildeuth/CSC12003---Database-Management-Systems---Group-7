USE QLST
GO

-- Thêm phân loại khách hàng
CREATE OR ALTER PROCEDURE ThemPhanLoai
    @Loai NVARCHAR(20),
    @DieuKien MONEY,
    @GiaTri MONEY
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra nếu loại đã tồn tại
        IF EXISTS (SELECT 1 FROM PHAN_LOAI WITH (UPDLOCK, HOLDLOCK) WHERE Loai = @Loai)
            THROW 50000, 'Loại khách hàng đã tồn tại.', 1

        -- Kiểm tra tính hợp lệ của các giá trị
        IF @DieuKien < 0 OR @GiaTri < 0
            THROW 50000, 'Điều kiện hoặc giá trị không hợp lệ.', 1

        -- Thêm loại khách hàng mới
        INSERT INTO PHAN_LOAI (Loai, DieuKien, GiaTri)
        VALUES (@Loai, @DieuKien, @GiaTri)

        COMMIT TRAN
        PRINT N'Thêm loại khách hàng thành công.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Cập nhật phân loại khách hàng
CREATE OR ALTER PROCEDURE CapNhatPhanLoai
    @Loai NVARCHAR(20),
    @DieuKien MONEY = NULL,
    @GiaTri MONEY = NULL
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Repeatable Read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra loại khách hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM PHAN_LOAI WITH (UPDLOCK, HOLDLOCK) WHERE Loai = @Loai)
            THROW 50000, 'Loại khách hàng không tồn tại.', 1

        -- Kiểm tra tính hợp lệ của các giá trị (nếu được truyền vào)
        IF @DieuKien IS NOT NULL AND @DieuKien < 0
            THROW 50000, 'Điều kiện không hợp lệ.', 1

        IF @GiaTri IS NOT NULL AND @GiaTri < 0
            THROW 50000, 'Giá trị không hợp lệ.', 1

        -- Cập nhật thông tin loại khách hàng
        UPDATE PHAN_LOAI
        SET 
            DieuKien = COALESCE(@DieuKien, DieuKien),
            GiaTri = COALESCE(@GiaTri, GiaTri)
        WHERE Loai = @Loai

        COMMIT TRAN
        PRINT N'Cập nhật loại khách hàng thành công.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- Xóa phân loại khách hàng
CREATE OR ALTER PROCEDURE XoaPhanLoai
    @Loai NVARCHAR(20)
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Serializable
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        -- Kiểm tra loại khách hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM PHAN_LOAI WITH (UPDLOCK, HOLDLOCK) WHERE Loai = @Loai)
            THROW 50000, 'Loại khách hàng không tồn tại.', 1

        -- Kiểm tra nếu có khách hàng hoặc chi tiết khuyến mãi thuộc phân loại này
        IF EXISTS (SELECT 1 FROM KHACH_HANG WHERE LoaiKhachHang = @Loai)
            THROW 50000, 'Tồn tại khách hàng thuộc phân loại.', 1

        IF EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_MEMBER WHERE LoaiKhachHang = @Loai)
            THROW 50000, 'Tồn tại chi tiết khuyến mãi member thuộc phân loại.', 1

        -- Xóa loại khách hàng
        DELETE FROM PHAN_LOAI WHERE Loai = @Loai

        COMMIT TRAN
        PRINT N'Xóa loại khách hàng thành công.'
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
