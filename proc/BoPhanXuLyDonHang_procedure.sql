USE QLST
GO
-- Chỉnh sửa bảng Hóa đơn thêm Trạng thái thanh toán
IF NOT EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'HOA_DON'
      AND COLUMN_NAME = 'TrangThaiThanhToan'
)
BEGIN
    ALTER TABLE HOA_DON
	ADD TrangThaiThanhToan BIT DEFAULT 0
END
GO

-- Bộ phận quản lý kho hàng

-- Thêm sản phẩm vào phiếu mua sắm
CREATE OR ALTER PROCEDURE ThemSanPhamVaoPhieuMuaSam
    @MaPhieuMuaSam INT,
    @MaSanPham INT,
    @SoLuong INT
AS
BEGIN
    BEGIN TRANSACTION

    BEGIN TRY
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- 1. Kiểm tra phiếu mua sắm
        SELECT TOP 1 1
        FROM PHIEU_MUA_SAM WITH (HOLDLOCK) -- Shared Lock
        WHERE MaPhieuMuaSam = @MaPhieuMuaSam

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Phiếu mua sắm không tồn tại.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END

        -- 2. Kiểm tra sản phẩm
        SELECT TOP 1 1
        FROM SAN_PHAM WITH (HOLDLOCK) -- Shared Lock
        WHERE MaSanPham = @MaSanPham
		
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Sản phẩm không tồn tại.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END

        -- 3. Kiểm tra tồn kho
        DECLARE @SoLuongTon INT
        SELECT @SoLuongTon = SoLuongTonKhoHienTai
        FROM SAN_PHAM WITH (HOLDLOCK) -- Shared Lock
        WHERE MaSanPham = @MaSanPham

        IF @SoLuongTon < @SoLuong
        BEGIN
            RAISERROR('Không đủ tồn kho.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
		
        -- 4. Cập nhật hoặc thêm sản phẩm vào chi tiết phiếu mua sắm
        IF EXISTS (SELECT 1 FROM CHI_TIET_PHIEU_MUA_SAM WHERE MaPhieuMuaSam = @MaPhieuMuaSam AND MaSanPham = @MaSanPham)
        BEGIN
            -- Cập nhật số lượng sản phẩm
            UPDATE CHI_TIET_PHIEU_MUA_SAM WITH (ROWLOCK) -- Exclusive Lock
            SET SoLuongDat = SoLuongDat + @SoLuong
            WHERE MaPhieuMuaSam = @MaPhieuMuaSam AND MaSanPham = @MaSanPham
        END
        ELSE
        BEGIN
            -- Thêm sản phẩm mới
            INSERT INTO CHI_TIET_PHIEU_MUA_SAM (MaPhieuMuaSam, MaSanPham, SoLuongDat)
            VALUES (@MaPhieuMuaSam, @MaSanPham, @SoLuong)
        END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO

-- Áp dụng khuyến mãi sản phẩm
CREATE OR ALTER PROCEDURE LayDanhSachKhuyenMaiHienTaiCuaSanPham
    @LoaiKhachHang NVARCHAR(50) = NULL,
    @MaSanPham1 INT,
    @MaSanPham2 INT = NULL
AS
BEGIN
    -- Gộp kết quả từ các loại khuyến mãi
    WITH DanhSachKhuyenMai AS (
        -- Lấy khuyến mãi FLASH
        SELECT 
            KM.MaKhuyenMai, 
            KM.TenKhuyenMai, 
            KM.NgayBatDau, 
            KM.NgayKetThuc, 
            CKMF.GiaTriKhuyenMai, 
            'FLASH' AS LoaiKhuyenMai
        FROM KHUYEN_MAI KM WITH (HOLDLOCK)
        INNER JOIN CHI_TIET_KHUYEN_MAI_FLASH CKMF WITH (HOLDLOCK)
            ON KM.MaKhuyenMai = CKMF.MaKhuyenMai
        WHERE CKMF.MaSanPham = @MaSanPham1
          AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()
        
        UNION ALL
        
        -- Lấy khuyến mãi MEMBER (nếu @LoaiKhachHang không NULL)
        SELECT 
            KM.MaKhuyenMai, 
            KM.TenKhuyenMai, 
            KM.NgayBatDau, 
            KM.NgayKetThuc, 
            CKMM.GiaTriKhuyenMai, 
            'MEMBER' AS LoaiKhuyenMai
        FROM KHUYEN_MAI KM WITH (HOLDLOCK)
        INNER JOIN CHI_TIET_KHUYEN_MAI_MEMBER CKMM WITH (HOLDLOCK)
            ON KM.MaKhuyenMai = CKMM.MaKhuyenMai
        WHERE CKMM.MaSanPham = @MaSanPham1
          AND (@LoaiKhachHang IS NOT NULL)
          AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()
        
        UNION ALL
        
        -- Lấy khuyến mãi COMBO (nếu @MaSanPham2 không NULL)
        SELECT 
            KM.MaKhuyenMai, 
            KM.TenKhuyenMai, 
            KM.NgayBatDau, 
            KM.NgayKetThuc, 
            CKMC.GiaTriKhuyenMai, 
            'COMBO' AS LoaiKhuyenMai
        FROM KHUYEN_MAI KM WITH (HOLDLOCK)
        INNER JOIN CHI_TIET_KHUYEN_MAI_COMBO CKMC WITH (HOLDLOCK)
            ON KM.MaKhuyenMai = CKMC.MaKhuyenMai
        WHERE (CKMC.MaSanPham1 = @MaSanPham1 OR CKMC.MaSanPham2 = @MaSanPham2)
          AND (@MaSanPham2 IS NOT NULL)
          AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()
    )

    -- Sắp xếp kết quả theo yêu cầu
    SELECT *
    FROM DanhSachKhuyenMai
    ORDER BY 
        CASE 
            WHEN LoaiKhuyenMai = 'FLASH' THEN 1
            WHEN LoaiKhuyenMai = 'COMBO' THEN 2
            WHEN LoaiKhuyenMai = 'MEMBER' THEN 3
        END,
        GiaTriKhuyenMai DESC; -- Giá trị khuyến mãi cao hơn ưu tiên
END
GO

-- Lấy danh sách khuyến mãi hiện tại
CREATE OR ALTER PROCEDURE ApDungKhuyenMaiSanPham
    @MaSanPham1 INT,
    @SoLuong1 INT,
    @MaSanPham2 INT = NULL,
    @SoLuong2 INT = NULL,
    @LoaiKhachHang NVARCHAR(50),
    @GiaSauKhuyenMai1 MONEY OUTPUT,
    @GiaSauKhuyenMai2 MONEY OUTPUT
AS
BEGIN
    BEGIN TRANSACTION

    BEGIN TRY
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED

        -- Tạo bảng tạm để lưu danh sách khuyến mãi
        CREATE TABLE #DanhSachKhuyenMai (
            MaKhuyenMai INT,
            TenKhuyenMai NVARCHAR(200),
            NgayBatDau DATE,
            NgayKetThuc DATE,
            GiaTriKhuyenMai FLOAT,
            LoaiKhuyenMai NVARCHAR(20)
        )

        -- Xử lý sản phẩm 1
        IF @SoLuong1 > 0
        BEGIN
            -- Gọi procedure để lấy danh sách khuyến mãi
            INSERT INTO #DanhSachKhuyenMai
            EXEC LayDanhSachKhuyenMaiHienTaiCuaSanPham @LoaiKhachHang, @MaSanPham1, @MaSanPham2

            -- Lấy khuyến mãi ưu tiên cao nhất
            DECLARE @GiaTriKhuyenMai1 FLOAT, @LoaiKhuyenMai1 NVARCHAR(20)
            SELECT TOP 1 
                @GiaTriKhuyenMai1 = GiaTriKhuyenMai, 
                @LoaiKhuyenMai1 = LoaiKhuyenMai
            FROM #DanhSachKhuyenMai
            WHERE MaKhuyenMai IS NOT NULL
            ORDER BY GiaTriKhuyenMai DESC

            -- Kiểm tra số lượng và tính giá
            IF @GiaTriKhuyenMai1 IS NOT NULL
            BEGIN
                SELECT @GiaSauKhuyenMai1 = GiaNiemYet * (1 - @GiaTriKhuyenMai1 / 100)
                FROM SAN_PHAM WITH (HOLDLOCK)
                WHERE MaSanPham = @MaSanPham1
            END
            ELSE
            BEGIN
                SELECT @GiaSauKhuyenMai1 = GiaNiemYet
                FROM SAN_PHAM WITH (HOLDLOCK)
                WHERE MaSanPham = @MaSanPham1
            END
        END

        -- Xử lý sản phẩm 2 (nếu tồn tại)
        IF @MaSanPham2 IS NOT NULL AND @SoLuong2 > 0
        BEGIN
            -- Dọn bảng tạm trước khi xử lý sản phẩm 2
            TRUNCATE TABLE #DanhSachKhuyenMai

            -- Gọi procedure để lấy danh sách khuyến mãi
            INSERT INTO #DanhSachKhuyenMai
            EXEC LayDanhSachKhuyenMaiHienTaiCuaSanPham @LoaiKhachHang, @MaSanPham2, NULL

            -- Lấy khuyến mãi ưu tiên cao nhất
            DECLARE @GiaTriKhuyenMai2 FLOAT, @LoaiKhuyenMai2 NVARCHAR(20)
            SELECT TOP 1 
                @GiaTriKhuyenMai2 = GiaTriKhuyenMai, 
                @LoaiKhuyenMai2 = LoaiKhuyenMai
            FROM #DanhSachKhuyenMai
            WHERE MaKhuyenMai IS NOT NULL
            ORDER BY GiaTriKhuyenMai DESC

            -- Kiểm tra số lượng và tính giá
            IF @GiaTriKhuyenMai2 IS NOT NULL
            BEGIN
                SELECT @GiaSauKhuyenMai2 = GiaNiemYet * (1 - @GiaTriKhuyenMai2 / 100)
                FROM SAN_PHAM WITH (HOLDLOCK)
                WHERE MaSanPham = @MaSanPham2
            END
            ELSE
            BEGIN
                SELECT @GiaSauKhuyenMai2 = GiaNiemYet
                FROM SAN_PHAM WITH (HOLDLOCK)
                WHERE MaSanPham = @MaSanPham2
            END
        END

        -- Dọn dẹp bảng tạm
        DROP TABLE #DanhSachKhuyenMai

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        -- Dọn dẹp bảng tạm trong trường hợp lỗi
        IF OBJECT_ID('tempdb..#DanhSachKhuyenMai') IS NOT NULL
        BEGIN
            DROP TABLE #DanhSachKhuyenMai
        END

        -- Ném lại lỗi chi tiết
        DECLARE @ErrorNumber INT = ERROR_NUMBER()
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

-- Tạo hóa đơn
CREATE OR ALTER PROCEDURE TaoHoaDon
    @MaPhieuMuaSam INT,
    @MaHoaDon INT OUTPUT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE -- Đặt mức cô lập cao nhất
    BEGIN TRANSACTION

    BEGIN TRY
        -- 1. Tạo hóa đơn mới
        INSERT INTO HOA_DON (MaPhieuMuaSam, TrangThaiThanhToan)
        VALUES (@MaPhieuMuaSam, 0)

        -- Lấy MaHoaDon vừa tạo
        SET @MaHoaDon = SCOPE_IDENTITY()

        -- 2. Lấy loại khách hàng thông qua MaKhachHang trong bảng PHIEU_MUA_SAM
        DECLARE @LoaiKhachHang NVARCHAR(50)
        SELECT @LoaiKhachHang = KH.LoaiKhachHang
        FROM PHIEU_MUA_SAM PMS
        INNER JOIN KHACH_HANG KH ON PMS.MaKhachHang = KH.MaKhachHang
        WHERE PMS.MaPhieuMuaSam = @MaPhieuMuaSam

        -- 3. Lấy danh sách chi tiết sản phẩm trong phiếu mua sắm
        DECLARE @MaSanPham INT, @SoLuong INT
        DECLARE @GiaSauKhuyenMai MONEY

        DECLARE product_cursor CURSOR FOR
        SELECT MaSanPham, SoLuongDat
        FROM CHI_TIET_PHIEU_MUA_SAM
        WHERE MaPhieuMuaSam = @MaPhieuMuaSam

        OPEN product_cursor
        FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong

        -- 4. Duyệt qua từng sản phẩm trong phiếu mua sắm
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Gọi stored procedure ApDungKhuyenMaiSanPham để lấy giá sau khuyến mãi
            EXEC ApDungKhuyenMaiSanPham 
                @MaSanPham1 = @MaSanPham, 
                @SoLuong1 = @SoLuong, 
                @LoaiKhachHang = @LoaiKhachHang, 
                @GiaSauKhuyenMai1 = @GiaSauKhuyenMai OUTPUT,
				@GiaSauKhuyenMai2 = @GiaSauKhuyenMai OUTPUT

            -- Thêm chi tiết hóa đơn
            INSERT INTO CHI_TIET_HOA_DON (MaHoaDon, MaSanPham, SoLuong, GiaBan)
            VALUES (@MaHoaDon, @MaSanPham, 
                    CASE WHEN @SoLuong > 3 THEN 3 ELSE @SoLuong END, 
                    @GiaSauKhuyenMai)

            FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong
        END

        CLOSE product_cursor
        DEALLOCATE product_cursor

        -- 5. Cập nhật trạng thái thanh toán hóa đơn là chưa thanh toán
        UPDATE HOA_DON
        SET TrangThaiThanhToan = 0
        WHERE MaHoaDon = @MaHoaDon

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO


-- Xuất hóa đơn
CREATE OR ALTER PROCEDURE XuatHoaDon
    @MaHoaDon INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ -- Ngăn chặn Lost Update
    BEGIN TRANSACTION

    BEGIN TRY
        -- 1. Kiểm tra xem mã hóa đơn có tồn tại không
        IF NOT EXISTS(SELECT 1 FROM HOA_DON WHERE MaHoaDon = @MaHoaDon)
        BEGIN
            RAISERROR('Mã hóa đơn không tồn tại.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END

        -- 2. Cập nhật trạng thái thanh toán
        UPDATE HOA_DON
        SET TrangThaiThanhToan = 1
        WHERE MaHoaDon = @MaHoaDon

        -- 3. Lấy thông tin khách hàng từ hóa đơn
        DECLARE @MaKhachHang INT
        SELECT @MaKhachHang = PMS.MaKhachHang
        FROM HOA_DON HD
        INNER JOIN PHIEU_MUA_SAM PMS ON HD.MaPhieuMuaSam = PMS.MaPhieuMuaSam
        WHERE HD.MaHoaDon = @MaHoaDon

        -- 4. Lấy danh sách chi tiết hóa đơn
        DECLARE @MaSanPham INT, @SoLuong INT, @LoaiKhuyenMai NVARCHAR(20)
        DECLARE @GiaTriKhuyenMai FLOAT
        DECLARE product_cursor CURSOR FOR
        SELECT MaSanPham, SoLuong
        FROM CHI_TIET_HOA_DON
        WHERE MaHoaDon = @MaHoaDon

        OPEN product_cursor
        FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong

        -- 5. Xử lý từng sản phẩm trong hóa đơn
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- 5.1 Kiểm tra tồn kho
            DECLARE @SoLuongTon INT
            SELECT @SoLuongTon = SoLuongTonKhoHienTai FROM SAN_PHAM WHERE MaSanPham = @MaSanPham

            IF @SoLuongTon < @SoLuong
            BEGIN
                RAISERROR('Không đủ hàng tồn kho để xuất hóa đơn.', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END

            -- 5.2 Giảm số lượng tồn kho
            UPDATE SAN_PHAM
            SET SoLuongTonKhoHienTai = SoLuongTonKhoHienTai - @SoLuong
            WHERE MaSanPham = @MaSanPham

            -- 5.3 Lấy khuyến mãi áp dụng
            SELECT TOP 1 @GiaTriKhuyenMai = GiaTriKhuyenMai, @LoaiKhuyenMai = LoaiKhuyenMai
            FROM (
                SELECT CKMF.GiaTriKhuyenMai, 'FLASH' AS LoaiKhuyenMai
                FROM CHI_TIET_KHUYEN_MAI_FLASH CKMF
                WHERE CKMF.MaSanPham = @MaSanPham AND CKMF.SoLuongConLai >= @SoLuong

                UNION ALL

                SELECT CKMM.GiaTriKhuyenMai, 'MEMBER' AS LoaiKhuyenMai
                FROM CHI_TIET_KHUYEN_MAI_MEMBER CKMM
                WHERE CKMM.MaSanPham = @MaSanPham AND CKMM.SoLuongConLai >= @SoLuong
            ) AS DSKhuyenMai
            ORDER BY LoaiKhuyenMai DESC -- Ưu tiên khuyến mãi FLASH

            -- 5.4 Giảm số lượng khuyến mãi (nếu áp dụng)
            IF @GiaTriKhuyenMai IS NOT NULL
            BEGIN
                IF @LoaiKhuyenMai = 'FLASH'
                BEGIN
                    UPDATE CHI_TIET_KHUYEN_MAI_FLASH
                    SET SoLuongConLai = SoLuongConLai - @SoLuong
                    WHERE MaSanPham = @MaSanPham
                END
                ELSE IF @LoaiKhuyenMai = 'MEMBER'
                BEGIN
                    UPDATE CHI_TIET_KHUYEN_MAI_MEMBER
                    SET SoLuongConLai = SoLuongConLai - @SoLuong
                    WHERE MaSanPham = @MaSanPham
                END
            END

            FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong
        END

        CLOSE product_cursor
        DEALLOCATE product_cursor

        -- 6. Cập nhật điểm thưởng cho khách hàng
        DECLARE @TongTien FLOAT
        SELECT @TongTien = SUM(SoLuong * GiaBan) 
        FROM CHI_TIET_HOA_DON 
        WHERE MaHoaDon = @MaHoaDon

        IF @MaKhachHang IS NOT NULL
        BEGIN
            UPDATE KHACH_HANG
            SET TienTichLuy = TienTichLuy + FLOOR(@TongTien / 1000) -- Cứ 1000 đồng = 1 điểm
            WHERE MaKhachHang = @MaKhachHang
        END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END
GO


