USE QLST
GO

-- Thêm chương trình khuyến mãi
CREATE OR ALTER PROCEDURE ThemChuongTrinhKhuyenMai
    @TenKhuyenMai NVARCHAR(200),
    @LoaiKhuyenMai NVARCHAR(10),
    @NgayBatDau DATE,
    @NgayKetThuc DATE,
    @DanhSachKhuyenMaiChiTiet DanhSachKhuyenMaiChiTietType READONLY
AS
BEGIN
    -- Bắt đầu giao dịch
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập (Read Committed)
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        DECLARE @MaKhuyenMai INT, @RowsInserted INT = 0

        -- Gọi thủ tục để tạo mã khuyến mãi
        EXEC @MaKhuyenMai = dbo.TaoMaKhuyenMai 
            @TenKhuyenMai = @TenKhuyenMai, 
            @LoaiKhuyenMai = @LoaiKhuyenMai, 
            @NgayBatDau = @NgayBatDau, 
            @NgayKetThuc = @NgayKetThuc

        -- Duyệt qua danh sách chi tiết khuyến mãi
        DECLARE @MaSanPham INT, @GiaTriKhuyenMai FLOAT, @SoLuongConLai INT, @MaSanPham2 INT, @LoaiKhachHang NVARCHAR(20)

        DECLARE ChiTietCursor CURSOR FOR
            SELECT MaSanPham, GiaTriKhuyenMai, SoLuongConLai, MaSanPham2, LoaiKhachHang
            FROM @DanhSachKhuyenMaiChiTiet

        OPEN ChiTietCursor
        FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Kiểm tra chi tiết theo loại khuyến mãi
            IF dbo.KiemTraTheoLoaiKhuyenMai(@LoaiKhuyenMai, @MaSanPham, @GiaTriKhuyenMai, @MaSanPham2, @LoaiKhachHang) = 0
            BEGIN
                PRINT N'Chi tiết khuyến mãi không hợp lệ cho mã sản phẩm: ' + CAST(@MaSanPham AS NVARCHAR)
                FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang
                CONTINUE
            END

            -- Thêm chi tiết khuyến mãi
            IF @LoaiKhuyenMai = 'Flash'
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_FLASH WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham)
                BEGIN
                    INSERT INTO CHI_TIET_KHUYEN_MAI_FLASH WITH (XLOCK) -- Sử dụng XLOCK để ngăn cập nhật đồng thời
                    VALUES (@MaKhuyenMai, @MaSanPham, @SoLuongConLai, @GiaTriKhuyenMai)
                    SET @RowsInserted = @RowsInserted + @@ROWCOUNT
                END
            END
            ELSE IF @LoaiKhuyenMai = 'Combo'
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_COMBO WHERE MaKhuyenMai = @MaKhuyenMai AND ((MaSanPham1 = @MaSanPham AND MaSanPham2 = @MaSanPham2) OR (MaSanPham1 = @MaSanPham2 AND MaSanPham2 = @MaSanPham)))
                BEGIN
                    INSERT INTO CHI_TIET_KHUYEN_MAI_COMBO WITH (XLOCK)
                    VALUES (@MaKhuyenMai, @MaSanPham, @MaSanPham2, @SoLuongConLai, @GiaTriKhuyenMai)
                    SET @RowsInserted = @RowsInserted + @@ROWCOUNT
                END
            END
            ELSE IF @LoaiKhuyenMai = 'Member'
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_MEMBER WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham AND LoaiKhachHang = @LoaiKhachHang)
                BEGIN
                    INSERT INTO CHI_TIET_KHUYEN_MAI_MEMBER WITH (XLOCK)
                    VALUES (@MaKhuyenMai, @MaSanPham, @LoaiKhachHang, @SoLuongConLai, @GiaTriKhuyenMai)
                    SET @RowsInserted = @RowsInserted + @@ROWCOUNT
                END
            END

            FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang
        END

        CLOSE ChiTietCursor
        DEALLOCATE ChiTietCursor

        PRINT N'Số lượng chi tiết khuyến mãi đã thêm: ' + CAST(@RowsInserted AS NVARCHAR)

        -- Commit giao dịch
        COMMIT TRAN
    END TRY
    BEGIN CATCH 
        -- Xử lý rollback nếu giao dịch vẫn đang mở
        IF XACT_STATE() <> 0 -- Chỉ rollback nếu giao dịch khả dụng
            ROLLBACK TRAN;
        THROW
    END CATCH
END
GO


-- Cập nhật chương trình khuyến mãi
CREATE OR ALTER PROCEDURE CapNhatChuongTrinhKhuyenMai
    @MaKhuyenMai INT,
    @TenKhuyenMai NVARCHAR(200) = NULL,
    @NgayBatDau DATE = NULL,
    @NgayKetThuc DATE = NULL,
    @DanhSachKhuyenMaiChiTiet DanhSachKhuyenMaiChiTietType READONLY
AS
BEGIN
    BEGIN TRAN
    BEGIN TRY
        -- Thiết lập mức cô lập Repeatable Read
        SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

        -- Kiểm tra chương trình khuyến mãi tồn tại
        IF NOT EXISTS (
            SELECT 1 
            FROM KHUYEN_MAI WITH (UPDLOCK, HOLDLOCK) -- Khóa ngăn sửa đổi đồng thời
            WHERE MaKhuyenMai = @MaKhuyenMai
        )
            THROW 50000, 'Chương trình khuyến mãi không tồn tại.', 1

        -- Lấy loại khuyến mãi hiện tại và kiểm tra ngày kết thúc >= ngày bắt đầu (nếu được cập nhật)
        DECLARE @LoaiKhuyenMai NVARCHAR(10)

        IF @NgayBatDau IS NOT NULL OR @NgayKetThuc IS NOT NULL 
        BEGIN
            DECLARE @NgayBatDauCu DATE, @NgayKetThucCu DATE
            SELECT @LoaiKhuyenMai = LoaiKhuyenMai, @NgayBatDauCu = NgayBatDau, @NgayKetThucCu = NgayKetThuc 
            FROM KHUYEN_MAI WITH (UPDLOCK, HOLDLOCK) -- Khóa để ngăn dữ liệu bị thay đổi
            WHERE MaKhuyenMai = @MaKhuyenMai

            IF @NgayBatDau IS NULL
                SET @NgayBatDau = @NgayBatDauCu
            IF @NgayKetThuc IS NULL
                SET @NgayKetThuc = @NgayKetThucCu

            IF @NgayKetThuc < @NgayBatDau
                THROW 50000, 'Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.', 1
        END
        ELSE
        BEGIN
            SELECT @LoaiKhuyenMai = LoaiKhuyenMai 
            FROM KHUYEN_MAI WITH (UPDLOCK, HOLDLOCK) -- Khóa để ngăn dữ liệu bị thay đổi
            WHERE MaKhuyenMai = @MaKhuyenMai
        END

        -- Cập nhật thông tin chương trình khuyến mãi
        UPDATE KHUYEN_MAI
        SET 
            TenKhuyenMai = COALESCE(@TenKhuyenMai, TenKhuyenMai),
            NgayBatDau = COALESCE(@NgayBatDau, NgayBatDau),
            NgayKetThuc = COALESCE(@NgayKetThuc, NgayKetThuc)
        WHERE MaKhuyenMai = @MaKhuyenMai

        -- Duyệt qua danh sách chi tiết khuyến mãi
        DECLARE @MaSanPham INT, @GiaTriKhuyenMai FLOAT, @SoLuongConLai INT, @MaSanPham2 INT, @LoaiKhachHang NVARCHAR(20)
        DECLARE @RowsInserted INT = 0

        DECLARE ChiTietCursor CURSOR FOR
            SELECT MaSanPham, GiaTriKhuyenMai, SoLuongConLai, MaSanPham2, LoaiKhachHang
            FROM @DanhSachKhuyenMaiChiTiet

        OPEN ChiTietCursor
        FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Kiểm tra chi tiết theo loại khuyến mãi
            IF dbo.KiemTraTheoLoaiKhuyenMai(@LoaiKhuyenMai, @MaSanPham, @GiaTriKhuyenMai, @MaSanPham2, @LoaiKhachHang) = 0
            BEGIN
                PRINT N'Chi tiết khuyến mãi không hợp lệ cho mã sản phẩm: ' + CAST(@MaSanPham AS NVARCHAR)
                FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang
                CONTINUE
            END

            -- Cập nhật hoặc thêm chi tiết khuyến mãi vào bảng tương ứng
            IF @LoaiKhuyenMai = 'Flash'
            BEGIN
                IF EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_FLASH WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham)
                    UPDATE CHI_TIET_KHUYEN_MAI_FLASH
                    SET 
                        SoLuongConLai = COALESCE(@SoLuongConLai, SoLuongConLai),
                        GiaTriKhuyenMai = COALESCE(@GiaTriKhuyenMai, GiaTriKhuyenMai)
                    WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham
                ELSE
                    INSERT INTO CHI_TIET_KHUYEN_MAI_FLASH (MaKhuyenMai, MaSanPham, SoLuongConLai, GiaTriKhuyenMai)
                    VALUES (@MaKhuyenMai, @MaSanPham, @SoLuongConLai, @GiaTriKhuyenMai)
                SET @RowsInserted = @RowsInserted + @@ROWCOUNT
            END
            ELSE IF @LoaiKhuyenMai = 'Combo'
            BEGIN
                IF EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_COMBO WHERE MaKhuyenMai = @MaKhuyenMai AND ((MaSanPham1 = @MaSanPham AND MaSanPham2 = @MaSanPham2) OR (MaSanPham1 = @MaSanPham2 AND MaSanPham2 = @MaSanPham)))
                    UPDATE CHI_TIET_KHUYEN_MAI_COMBO
                    SET 
                        SoLuongConLai = COALESCE(@SoLuongConLai, SoLuongConLai),
                        GiaTriKhuyenMai = COALESCE(@GiaTriKhuyenMai, GiaTriKhuyenMai)
                    WHERE MaKhuyenMai = @MaKhuyenMai AND ((MaSanPham1 = @MaSanPham AND MaSanPham2 = @MaSanPham2) OR (MaSanPham1 = @MaSanPham2 AND MaSanPham2 = @MaSanPham))
                ELSE
                    INSERT INTO CHI_TIET_KHUYEN_MAI_COMBO (MaKhuyenMai, MaSanPham1, MaSanPham2, SoLuongConLai, GiaTriKhuyenMai)
                    VALUES (@MaKhuyenMai, @MaSanPham, @MaSanPham2, @SoLuongConLai, @GiaTriKhuyenMai)
                SET @RowsInserted = @RowsInserted + @@ROWCOUNT
            END
            ELSE IF @LoaiKhuyenMai = 'Member'
            BEGIN
                IF EXISTS (SELECT 1 FROM CHI_TIET_KHUYEN_MAI_MEMBER WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham AND LoaiKhachHang = @LoaiKhachHang)
                    UPDATE CHI_TIET_KHUYEN_MAI_MEMBER
                    SET 
                        SoLuongConLai = COALESCE(@SoLuongConLai, SoLuongConLai),
                        GiaTriKhuyenMai = COALESCE(@GiaTriKhuyenMai, GiaTriKhuyenMai)
                    WHERE MaKhuyenMai = @MaKhuyenMai AND MaSanPham = @MaSanPham AND LoaiKhachHang = @LoaiKhachHang
                ELSE
                    INSERT INTO CHI_TIET_KHUYEN_MAI_MEMBER (MaKhuyenMai, MaSanPham, LoaiKhachHang, SoLuongConLai, GiaTriKhuyenMai)
                    VALUES (@MaKhuyenMai, @MaSanPham, @LoaiKhachHang, @SoLuongConLai, @GiaTriKhuyenMai)
                SET @RowsInserted = @RowsInserted + @@ROWCOUNT
            END

            FETCH NEXT FROM ChiTietCursor INTO @MaSanPham, @GiaTriKhuyenMai, @SoLuongConLai, @MaSanPham2, @LoaiKhachHang
        END

        CLOSE ChiTietCursor
        DEALLOCATE ChiTietCursor

        PRINT N'Số lượng chi tiết khuyến mãi đã thêm hoặc cập nhật: ' + CAST(@RowsInserted AS NVARCHAR)

        COMMIT TRAN
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        THROW
    END CATCH
END
GO
