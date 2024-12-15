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
        WHERE SanPhamID = @MaSanPham
		
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
        WHERE SanPhamID = @MaSanPham

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
CREATE OR ALTER PROCEDURE ApDungKhuyenMaiSanPham
    @MaSanPham INT,
    @SoLuong INT,
    @GiaSauKhuyenMai MONEY OUTPUT
AS
BEGIN
    BEGIN TRANSACTION

    BEGIN TRY
        -- Tạo bảng tạm để lưu danh sách khuyến mãi
        CREATE TABLE #DanhSachKhuyenMai (
            MaKhuyenMai INT,
            TenKhuyenMai NVARCHAR(200),
            NgayBatDau DATE,
            NgayKetThuc DATE,
            GiaTriKhuyenMai FLOAT,
            LoaiKhuyenMai NVARCHAR(20)
        )

        -- Gọi stored procedure để lấy danh sách khuyến mãi
        INSERT INTO #DanhSachKhuyenMai
        EXEC LayDanhSachKhuyenMaiHienTaiCuaSanPham @MaSanPham
		
        -- Lấy khuyến mãi ưu tiên cao nhất
        DECLARE @GiaTriKhuyenMai FLOAT, @LoaiKhuyenMai NVARCHAR(20)

        SELECT TOP 1 
            @GiaTriKhuyenMai = GiaTriKhuyenMai, 
            @LoaiKhuyenMai = LoaiKhuyenMai
        FROM #DanhSachKhuyenMai
        ORDER BY GiaTriKhuyenMai DESC

        -- Tính giá sau khuyến mãi
        IF @GiaTriKhuyenMai IS NOT NULL
        BEGIN
            SELECT @GiaSauKhuyenMai = GiaNiemYet * (1 - @GiaTriKhuyenMai / 100)
            FROM SAN_PHAM WITH (HOLDLOCK)
            WHERE SanPhamID = @MaSanPham
        END
        ELSE
        BEGIN
            SELECT @GiaSauKhuyenMai = GiaNiemYet
            FROM SAN_PHAM WITH (HOLDLOCK)
            WHERE SanPhamID = @MaSanPham
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


-- Lấy danh sách khuyến mãi hiện tại
CREATE OR ALTER PROCEDURE LayDanhSachKhuyenMaiHienTaiCuaSanPham
    @MaSanPham INT
AS
BEGIN
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
    WHERE CKMF.MaSanPham = @MaSanPham
      AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()

    UNION ALL

    -- Lấy khuyến mãi MEMBER
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
    WHERE CKMM.MaSanPham = @MaSanPham
      AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()

    UNION ALL

    -- Lấy khuyến mãi COMBO (nếu cần)
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
    WHERE CKMC.MaSanPham1 = @MaSanPham OR CKMC.MaSanPham2 = @MaSanPham
      AND KM.NgayBatDau <= GETDATE() AND KM.NgayKetThuc >= GETDATE()
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

        -- 2. Lấy danh sách chi tiết sản phẩm trong phiếu mua sắm
        DECLARE @MaSanPham INT, @SoLuong INT, @GiaBan MONEY
        DECLARE product_cursor CURSOR FOR
        SELECT MaSanPham, SoLuongDat
        FROM CHI_TIET_PHIEU_MUA_SAM
        WHERE MaPhieuMuaSam = @MaPhieuMuaSam

        OPEN product_cursor
        FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong

        -- 3. Duyệt qua từng sản phẩm
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Gọi stored procedure ApDungKhuyenMaiSanPham để lấy giá sau khuyến mãi
            EXEC ApDungKhuyenMaiSanPham @MaSanPham, @SoLuong, @GiaBan OUTPUT

            -- Thêm chi tiết hóa đơn
            INSERT INTO CHI_TIET_HOA_DON (MaHoaDon, MaSanPham, SoLuong, GiaBan)
            VALUES (@MaHoaDon, @MaSanPham, @SoLuong, @GiaBan)

            FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong
        END

        CLOSE product_cursor
        DEALLOCATE product_cursor

        -- 4. Cập nhật trạng thái thanh toán hóa đơn là chưa thanh toán
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

        -- 3. Lấy danh sách chi tiết hóa đơn
        DECLARE @MaSanPham INT, @SoLuong INT
        DECLARE product_cursor CURSOR FOR
        SELECT MaSanPham, SoLuong
        FROM CHI_TIET_HOA_DON
        WHERE MaHoaDon = @MaHoaDon

        OPEN product_cursor
        FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong

        -- 4. Giảm số lượng tồn kho
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Kiểm tra tồn kho trước khi giảm
            DECLARE @SoLuongTon INT
            SELECT @SoLuongTon = SoLuongTonKhoHienTai FROM SAN_PHAM WHERE SanPhamID = @MaSanPham

            IF @SoLuongTon < @SoLuong
            BEGIN
                RAISERROR('Không đủ hàng tồn kho để xuất hóa đơn.', 16, 1)
                ROLLBACK TRANSACTION
                RETURN
            END

            -- Giảm số lượng tồn kho
            UPDATE SAN_PHAM
            SET SoLuongTonKhoHienTai = SoLuongTonKhoHienTai - @SoLuong
            WHERE SanPhamID = @MaSanPham

            FETCH NEXT FROM product_cursor INTO @MaSanPham, @SoLuong
        END

        CLOSE product_cursor
        DEALLOCATE product_cursor

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        THROW
    END CATCH
END

