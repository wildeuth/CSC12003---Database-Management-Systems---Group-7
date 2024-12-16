USE QLST
GO

-- Stored Procedure: NhapHang
CREATE PROCEDURE NhapHang
    @MaSanPham INT,
    @NhaSanXuatID INT,
	@NgayNhan date,
    @SoLuongNhan INT
	
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    -- Exclusive lock for inserting into PHIEU_NHAN_HANG
    INSERT INTO PHIEU_NHAN_HANG (MaNhaSanXuat, MaSanPham, NgayNhan, SoLuongNhan)
    VALUES (@NhaSanXuatID, @MaSanPham, @NgayNhan, @SoLuongNhan);

    -- Update lock for updating stock quantity
    UPDATE SAN_PHAM WITH (UPDLOCK)
    SET SoLuongTonKhoHienTai = SoLuongTonKhoHienTai + @SoLuongNhan
    WHERE MaSanPham = @MaSanPham;

    COMMIT TRANSACTION;
END
GO

-- Stored Procedure: LayDanhSachDonDatHangDaNhan
CREATE PROCEDURE LayDanhSachDonDatHangDaNhan
    @MaSanPham INT,
    @NhaSanXuatID INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    -- Retrieve orders and receipts
    DECLARE @RemainingQuantity INT;

    DECLARE OrdersCursor CURSOR FOR
    SELECT pdh.MaSanPham, pdh.SoLuongDat, pnh.SoLuongNhan, pdh.DaNhanHang
    FROM PHIEU_DAT_HANG pdh WITH (HOLDLOCK)
    JOIN PHIEU_NHAN_HANG pnh WITH (HOLDLOCK)
        ON pdh.MaSanPham = pnh.MaSanPham
    WHERE pdh.MaSanPham = @MaSanPham AND pnh.MaNhaSanXuat = @NhaSanXuatID;

    OPEN OrdersCursor;

    FETCH NEXT FROM OrdersCursor INTO @RemainingQuantity;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Process orders
        IF @RemainingQuantity > 0
        BEGIN
            UPDATE PHIEU_DAT_HANG
            SET DaNhanHang = 1
            WHERE MaSanPham = @MaSanPham AND SoLuongDat <= @RemainingQuantity;

            SET @RemainingQuantity = @RemainingQuantity - SoLuongDat;
        END
        ELSE
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Insufficient quantity for receipt.';
            RETURN;
        END

        FETCH NEXT FROM OrdersCursor INTO @RemainingQuantity;
    END

    CLOSE OrdersCursor;
    DEALLOCATE OrdersCursor;

    COMMIT TRANSACTION;
END
GO
-- Stored Procedure: XuLyNhapHang
CREATE PROCEDURE XuLyNhapHang
    @MaSanPham INT,
    @NhaSanXuatID INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;

    -- Retrieve orders using LayDanhSachDonDatHangDaNhan
    EXEC LayDanhSachDonDatHangDaNhan @MaSanPham, @NhaSanXuatID;

    -- Process receipt
    UPDATE PHIEU_DAT_HANG
    SET DaNhanHang = 1
    WHERE MaSanPham = @MaSanPham AND MaNhaSanXuat = @NhaSanXuatID;

    PRINT 'Goods receipt processed successfully';

    COMMIT TRANSACTION;
END
GO