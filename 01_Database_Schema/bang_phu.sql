USE QLST
GO

CREATE TYPE DanhSachKhuyenMaiChiTietType AS TABLE
(
    MaSanPham INT,
    GiaTriKhuyenMai FLOAT,
    SoLuongConLai INT,
    MaSanPham2 INT,
    LoaiKhachHang NVARCHAR(20)
)
GO