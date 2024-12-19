-- Thủ tục chính: Thống kê số lượng khách hàng mua sản phẩm trong ngày:  sp_ThongKeKhachHangHangNgay
DECLARE @TongKhachHang INT;
EXEC sp_ThongKeKhachHangHangNgay @Ngay =  '2024-11-01 14:00:00.000', @Tong = @TongKhachHang OUTPUT;

---- Thủ tục: Lấy số lượng khách hàng đã mua sản phẩm: sp_LaySoLuongKhachHangMuaSanPham
exec sp_LaySoLuongKhachHangMuaSanPham @Ngay = '2024-11-01 14:00:00.000'

-- Thủ tục: Lấy danh sách sản pham đã bán trong ngày: sp_LayDanhSachSanPhamDaBan
exec sp_LayDanhSachSanPhamDaBan '2024-11-01 14:00:00.000'

-- Thủ tục chính: Tính tổng doanh thu hàng ngày
DECLARE @TongDThu DECIMAL(18, 2);

EXEC sp_TinhTongDoanhThuHangNgay @Ngay = '2024-11-01 14:00:00.000', @TongDThu = @TongDThu OUTPUT;

-- Thủ tục lấy danh sách hoá đơn trong ngày: sp_LayDanhSachHoaDonTrongNgay
exec sp_LayDanhSachHoaDonTrongNgay @Ngay = '2024-11-01 14:00:00.000'


-- Dữ liệu cho bảng PHAN_LOAI
INSERT INTO PHAN_LOAI (Loai, DieuKien, GiaTri)
VALUES 
(N'Thân thiết', 1000000, 50000),
(N'VIP', 5000000, 300000),
(N'Super VIP', 10000000, 800000);

-- Dữ liệu cho bảng KHACH_HANG
INSERT INTO KHACH_HANG (HoTen, Email, DiaChi, NgaySinh, SoDienThoai, LoaiKhachHang, TienTichLuy)
VALUES 
(N'Nguyễn Văn A', 'a@gmail.com', N'123 Lê Lợi, Quận 1', '1995-05-10', '0901234567', N'Thân thiết', 1500000),
(N'Trần Thị B', 'b@gmail.com', N'456 Nguyễn Trãi, Quận 5', '1990-03-21', '0912233442', N'VIP', 6000000),
(N'Lê Văn C', 'c@gmail.com', N'789 Trần Hưng Đạo, Quận 3', '1988-12-01', '0923344551', N'Super VIP', 12000000),
(N'Lê Văn D', 'c@gmail.com', N'788 Trần Hưng Đạo, Quận 3', '1989-12-01', '0923344553', N'Super VIP', 12000000),
(N'Lê Văn E', 'c@gmail.com', N'787 Trần Hưng Đạo, Quận 3', '1985-12-01', '0923344555', N'Super VIP', 12000000),
(N'Lê Văn F', 'c@gmail.com', N'786 Trần Hưng Đạo, Quận 3', '1986-12-01', '0923344556', N'Super VIP', 12000000)


-- Dữ liệu cho bảng DANH_MUC
INSERT INTO DANH_MUC (TenDanhMuc)
VALUES 
(N'Rau củ quả'),
(N'Bánh kẹo'),
(N'Đồ uống');

-- Dữ liệu cho bảng NHA_SAN_XUAT
INSERT INTO NHA_SAN_XUAT (TenNhaSanXuat)
VALUES 
(N'Vinamilk'),
(N'Orion'),
(N'Tân Hiệp Phát');

-- Dữ liệu cho bảng SAN_PHAM
INSERT INTO SAN_PHAM (TenSanPham, MoTa, GiaNiemYet, MaDanhMuc, MaNhaSanXuat, SoLuongTonKhoHienTai, SLSPTD)
VALUES 
(N'Sữa tươi Vinamilk 1L', N'Sữa tiệt trùng nguyên chất', 30000, 3, 1, 100, 50),
(N'Bánh Chocopie', N'Bánh mềm nhân marshmallow', 45000, 2, 2, 200, 100),
(N'Trà xanh không độ', N'Nước giải khát trà xanh', 10000, 3, 3, 300, 150);

-- Dữ liệu cho bảng KHUYEN_MAI
INSERT INTO KHUYEN_MAI (TenKhuyenMai, LoaiKhuyenMai, NgayBatDau, NgayKetThuc)
VALUES 
(N'Flash Sale 11/11', 'Flash', '2024-11-11', '2024-11-12'),
(N'Combo Tết 2024', 'Combo', '2024-01-15', '2024-01-31'),
(N'Khuyến mãi thành viên', 'Member', '2024-09-01', '2024-09-30');

-- Dữ liệu cho bảng CHI_TIET_KHUYEN_MAI_FLASH
INSERT INTO CHI_TIET_KHUYEN_MAI_FLASH (MaKhuyenMai, MaSanPham, SoLuongConLai, GiaTriKhuyenMai)
VALUES 
(1, 1, 50, 20),
(1, 2, 30, 15);

-- Dữ liệu cho bảng CHI_TIET_KHUYEN_MAI_COMBO
INSERT INTO CHI_TIET_KHUYEN_MAI_COMBO (MaKhuyenMai, MaSanPham1, MaSanPham2, SoLuongConLai, GiaTriKhuyenMai)
VALUES 
(2, 1, 2, 40, 25),
(2, 2, 3, 50, 30);

-- Dữ liệu cho bảng CHI_TIET_KHUYEN_MAI_MEMBER
INSERT INTO CHI_TIET_KHUYEN_MAI_MEMBER (MaKhuyenMai, MaSanPham, LoaiKhachHang, SoLuongConLai, GiaTriKhuyenMai)
VALUES 
(3, 3, N'Thân thiết', 60, 10),
(3, 1, N'VIP', 40, 20);

-- Dữ liệu cho bảng PHIEU_MUA_SAM
INSERT INTO PHIEU_MUA_SAM (MaKhachHang, NgayDat, LaOnline, SuDungPhieu)
VALUES 
(1, '2024-11-01 10:00:00.000', 1, 0),
(2, '2024-11-01 10:00:00.000', 0, 1),
(11, '2024-11-01 10:00:00.000', 1,0),
(10, '2024-11-01 10:00:00.000',1,0),
(9, '2024-11-01 10:00:00.000',1,0)

-- Dữ liệu cho bảng CHI_TIET_PHIEU_MUA_SAM
INSERT INTO CHI_TIET_PHIEU_MUA_SAM (MaPhieuMuaSam, MaSanPham, SoLuongDat)
VALUES 
(1, 1, 2),
(1, 2, 1),
(2, 3, 5),
(4,1,1),
(5,1,3),
(7,2,6)


-- Dữ liệu cho bảng HOA_DON
INSERT INTO HOA_DON (MaPhieuMuaSam, PhieuMuaHang, TrangThaiThanhToan, TongTien, ThanhToan)
VALUES 
(1, NULL, 1, 90000, 90000),
(2, NULL, 1, 50000, 50000),
(1,NULL,1,10000, 9000),
(4,NULL,1,12000, 9000),
(5,NULL,1,13000, 19000)

-- Dữ liệu cho bảng CHI_TIET_HOA_DON
INSERT INTO CHI_TIET_HOA_DON (MaHoaDon, MaSanPham, MaKhuyenMai, SoLuong, GiaBan, GiaSauKhuyenMai)
VALUES 
(1, 1, 1, 2, 30000, 24000),
(1, 2, 1, 1, 45000, 38250),
(2,1, 1, 3, 12000.0000, 12000.0000)
-- Dữ liệu cho bảng PHIEU_DAT_HANG
INSERT INTO PHIEU_DAT_HANG (MaNhaSanXuat, MaSanPham, SoLuongDat)
VALUES 
(1, 1, 500),
(2, 2, 300);

-- Dữ liệu cho bảng THONG_BAO
INSERT INTO THONG_BAO (MaKhachHang, NoiDung)
VALUES 
(1, N'Khuyến mãi lớn sắp diễn ra!'),
(2, N'Quý khách đã tích đủ điểm nhận ưu đãi.');

-- Dữ liệu cho bảng THONG_KE
INSERT INTO THONG_KE (NgayThongKe, TongDoanhThu, TongKhachHang)
VALUES 
('2024-11-01', 135000, 2),
('2024-11-02', 50000, 1);


