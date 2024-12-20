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
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
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
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRANSACTION;

    -- Biến để lưu số lượng còn lại
    DECLARE @RemainingQuantity INT;
    DECLARE @SoLuongDat INT;

    -- Con trỏ để duyệt danh sách đơn đặt hàng
    DECLARE OrdersCursor CURSOR FOR
    SELECT pdh.SoLuongDat, pnh.SoLuongNhan
    FROM PHIEU_DAT_HANG pdh
    JOIN PHIEU_NHAN_HANG pnh 
        ON pdh.MaSanPham = pnh.MaSanPham
    WHERE pdh.MaSanPham = @MaSanPham AND pnh.MaNhaSanXuat = @NhaSanXuatID
        AND pdh.DaNhanHang = 0;

    OPEN OrdersCursor;

    -- Lấy dữ liệu đầu tiên từ con trỏ
    FETCH NEXT FROM OrdersCursor INTO @SoLuongDat, @RemainingQuantity;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kiểm tra và xử lý số lượng còn lại
        IF @RemainingQuantity >= @SoLuongDat
        BEGIN
            -- Cập nhật trạng thái đã nhận hàng
            UPDATE PHIEU_DAT_HANG
            SET DaNhanHang = 1
            WHERE MaSanPham = @MaSanPham AND SoLuongDat = @SoLuongDat;

            -- Giảm số lượng còn lại
            SET @RemainingQuantity = @RemainingQuantity - @SoLuongDat;
        END
        ELSE
        BEGIN
            -- Nếu không đủ số lượng, rollback
            ROLLBACK TRANSACTION;
            PRINT 'Insufficient quantity for receipt.';
            RETURN;
        END

        -- Lấy bản ghi tiếp theo từ con trỏ
        FETCH NEXT FROM OrdersCursor INTO @SoLuongDat, @RemainingQuantity;
    END

    -- Đóng và hủy con trỏ
    CLOSE OrdersCursor;
    DEALLOCATE OrdersCursor;

    -- Hoàn tất giao dịch
    COMMIT TRANSACTION;
END;
GO
-- Stored Procedure: XuLyNhapHang
CREATE PROCEDURE XuLyNhapHang
    @MaSanPham INT,
    @NhaSanXuatID INT
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
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