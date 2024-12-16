USE QLST
GO

-- Thêm sản phẩm
CREATE OR ALTER PROCEDURE ThemSanPham
    @TenSanPham NVARCHAR(200),
    @MoTa NVARCHAR(255),
    @GiaNiemYet MONEY,
    @MaDanhMuc INT,
    @MaNhaSanXuat INT,
    @SoLuongTonKhoHienTai INT,
    @SLSPTD INT
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Read Committed
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Kiểm tra danh mục
        IF NOT EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK) -- Khóa để đảm bảo không bị thay đổi đồng thời
            WHERE MaDanhMuc = @MaDanhMuc
        )
            THROW 50000, 'Danh mục không tồn tại.', 1

        -- Kiểm tra nhà sản xuất
        IF NOT EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK) -- Khóa để ngăn các thay đổi đồng thời
            WHERE MaNhaSanXuat = @MaNhaSanXuat
        )
            THROW 50000, 'Nhà sản xuất không tồn tại.', 1

        -- Kiểm tra tên sản phẩm đã tồn tại
        IF EXISTS (
            SELECT 1 
            FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK) -- Khóa tránh xung đột khi kiểm tra trùng tên
            WHERE TenSanPham = @TenSanPham AND DaXoa = 0
        )
            THROW 50000, 'Tên sản phẩm đã được sử dụng.', 1

        -- Kiểm tra điều kiện hợp lệ
        IF @GiaNiemYet <= 0 OR @SoLuongTonKhoHienTai < 0 OR @SLSPTD <= 0
            THROW 50000, 'Giá hoặc số lượng không hợp lệ.', 1

        -- Thêm sản phẩm
        INSERT INTO SAN_PHAM (TenSanPham, MoTa, GiaNiemYet, MaDanhMuc, MaNhaSanXuat, SoLuongTonKhoHienTai, SLSPTD)
        VALUES (@TenSanPham, @MoTa, @GiaNiemYet, @MaDanhMuc, @MaNhaSanXuat, @SoLuongTonKhoHienTai, @SLSPTD)

        PRINT N'Thêm sản phẩm thành công.'
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN
        THROW -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO

-- Cập nhật sản phẩm
CREATE OR ALTER PROCEDURE CapNhatSanPham
    @MaSanPham INT,
    @TenSanPham NVARCHAR(200) = NULL,
    @MoTa NVARCHAR(255) = NULL,
    @GiaNiemYet MONEY = NULL,
    @MaDanhMuc INT = NULL,
    @MaNhaSanXuat INT = NULL,
    @SoLuongTonKhoHienTai INT = NULL,
    @SLSPTD INT = NULL
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Repeatable Read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra mã sản phẩm tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK)
            WHERE MaSanPham = @MaSanPham AND DaXoa = 0
        )
            THROW 50000, 'Mã sản phẩm không tồn tại.', 1

        -- Kiểm tra danh mục
        IF @MaDanhMuc IS NOT NULL AND NOT EXISTS (
            SELECT 1 
            FROM DANH_MUC WITH (UPDLOCK, HOLDLOCK)
            WHERE MaDanhMuc = @MaDanhMuc
        )
            THROW 50000, 'Danh mục không tồn tại.', 1

        -- Kiểm tra nhà sản xuất
        IF @MaNhaSanXuat IS NOT NULL AND NOT EXISTS (
            SELECT 1 
            FROM NHA_SAN_XUAT WITH (UPDLOCK, HOLDLOCK)
            WHERE MaNhaSanXuat = @MaNhaSanXuat
        )
            THROW 50000, 'Nhà sản xuất không tồn tại.', 1

        -- Kiểm tra tên sản phẩm đã tồn tại
        IF @TenSanPham IS NOT NULL AND EXISTS (
            SELECT 1 
            FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK)
            WHERE TenSanPham = @TenSanPham AND DaXoa = 0
        )
            THROW 50000, 'Tên sản phẩm đã được sử dụng.', 1

        -- Kiểm tra điều kiện hợp lệ
        IF @GiaNiemYet IS NOT NULL AND @GiaNiemYet <= 0
            THROW 50000, 'Giá không hợp lệ.', 1
        IF @SoLuongTonKhoHienTai IS NOT NULL AND @SoLuongTonKhoHienTai < 0
            THROW 50000, 'Số lượng tồn kho không hợp lệ.', 1
        IF @SLSPTD IS NOT NULL AND @SLSPTD <= 0
            THROW 50000, 'Số lượng tối đa không hợp lệ.', 1

        -- Cập nhật sản phẩm
        UPDATE SAN_PHAM
        SET 
            TenSanPham = COALESCE(@TenSanPham, TenSanPham),
            MoTa = COALESCE(@MoTa, MoTa),
            GiaNiemYet = COALESCE(@GiaNiemYet, GiaNiemYet),
            MaDanhMuc = COALESCE(@MaDanhMuc, MaDanhMuc),
            MaNhaSanXuat = COALESCE(@MaNhaSanXuat, MaNhaSanXuat),
            SoLuongTonKhoHienTai = COALESCE(@SoLuongTonKhoHienTai, SoLuongTonKhoHienTai),
            SLSPTD = COALESCE(@SLSPTD, SLSPTD)
        WHERE MaSanPham = @MaSanPham

        PRINT N'Cập nhật sản phẩm thành công.'
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN
        THROW -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO

-- Xóa sản phẩm
CREATE OR ALTER PROCEDURE XoaSanPham
    @MaSanPham INT
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Serializable
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

        -- Kiểm tra mã sản phẩm tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM SAN_PHAM WITH (UPDLOCK, HOLDLOCK)
            WHERE MaSanPham = @MaSanPham AND DaXoa = 0
        )
            THROW 50000, 'Mã sản phẩm không tồn tại.', 1

        -- Đánh dấu đã xóa sản phẩm
        UPDATE SAN_PHAM
        SET DaXoa = 1
        WHERE MaSanPham = @MaSanPham

        PRINT N'Xóa sản phẩm thành công.'
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- Chỉ rollback nếu giao dịch vẫn đang mở
            ROLLBACK TRAN
        THROW -- Kích hoạt lại lỗi ban đầu
    END CATCH
END
GO
