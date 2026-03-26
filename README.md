# Supermarket Management System (SMS)

**Course:** CSC12003 - Database Management Systems  
**Group:** Group 7  
**Academic Year:** 2024-2025

---

## 📋 Table of Contents

- [Introduction](#introduction)
- [System Architecture](#system-architecture)
- [Directory Structure](#directory-structure)
- [Main Features](#main-features)
- [Database](#database)
- [Usage Guide](#usage-guide)
- [Code Conventions](#code-conventions)

---

## 🎯 Introduction

The **Supermarket Management System (SMS)** is a comprehensive management application developed using SQL Server, including:

- ✅ Customer management with VIP classification system
- ✅ Inventory management and import/export operations
- ✅ Product catalog and manufacturer management
- ✅ Diverse promotion system (Flash, Combo, Member)
- ✅ Order processing and payment handling
- ✅ Detailed business analytics

---

## ⚡ Key Highlights

### 🎖️ **Advanced VIP Classification System**
- Multi-tier customer classification: Member, Copper, Silver, Gold, Platinum, Diamond
- Automatic loyalty point tracking and reward redemption
- Birthday voucher distribution system
- Customer segmentation for targeted promotions

### 🛍️ **Comprehensive Inventory Management**
- Real-time stock tracking and inventory monitoring
- Automatic reordering when stock falls below threshold
- Import/Export operations with full audit trail
- Maximum product quantity (SLSPTD) validation
- Goods receipt and purchase order management

### 💰 **Flexible Promotion Engine**
- **Flash Sale:** Time-limited discounts on specific products
- **Combo Offers:** Multi-product bundled discounts
- **Member Exclusive:** Loyalty tier-based promotions
- Promotion quantity and time period controls
- Automatic discount calculation and application

### 📊 **Business Intelligence & Analytics**
- Real-time sales dashboard and revenue tracking
- Customer purchase behavior analysis
- Daily sales and revenue statistics
- Product performance metrics
- Customer lifecycle insights

### 🔒 **Enterprise-Grade Data Integrity**
- ACID-compliant transaction management
- Soft delete pattern for data recovery
- Comprehensive foreign key relationships
- Data validation and constraint enforcement
- Concurrent access handling with proper locking strategies

### 🏗️ **Well-Organized Architecture**
- 13+ core database tables with relational integrity
- 6 logical procedure modules for maintainability
- Clear separation of concerns
- Scalable and extensible design
- Best practice SQL Server standards

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│             Application Layer                            │
├─────────────────────────────────────────────────────────┤
│          Stored Procedures & Business Logic              │
├─────────────────────────────────────────────────────────┤
│               Database Layer (SQL Server)                │
│  ┌────────────────────────────────────────────────────┐  │
│  │ Tables | Indexes | Constraints | Triggers          │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
CSC12003---Database-Management-Systems---Group-7/
│
├── 01_Database_Schema/
│   ├── scriptST.sql              # Script to create database & main tables
│   └── bang_phu.sql              # Custom types definition
│
├── 02_Stored_Procedures/
│   ├── 01_Customer_Management/
│   │   ├── khach_hang.sql        # Register, update customers
│   │   └── phan_loai.sql         # Customer classification management
│   │
│   ├── 02_Product_Management/
│   │   ├── san_pham.sql          # Product management
│   │   ├── danh_muc.sql          # Category management
│   │   └── nha_san_xuat.sql      # Manufacturer management
│   │
│   ├── 03_Inventory_Management/
│   │   ├── DatHang.sql           # Order & inventory check
│   │   └── NhapHang.sql          # Import goods & update inventory
│   │
│   ├── 04_Promotion_Management/
│   │   └── khuyen_mai.sql        # Promotion programs
│   │
│   ├── 05_Business_Analytics/
│   │   ├── ThongKeKhachHang.sql  # Customer analytics
│   │   └── TongDoanhThuTrongNgay.sql # Revenue statistics
│   │
│   └── 06_Order_Processing/
│       └── BoPhanXuLyDonHang_procedure.sql # Order processing
│
├── 03_Data_Initialization/
│   └── data.sql                  # Sample initialization data
│
├── 04_Functions_and_Types/
│   └── (Custom functions & types reference)
│
├── docs/
│   └── (Detailed technical documentation)
│
└── README.md                     # This file
```

---

## ⭐ Main Features

### 1. **Customer Management** 👥
- Register new customers
- Update customer information
- VIP classification: Member, Copper, Silver, Gold, Platinum, Diamond
- Loyalty points accumulation
- Birthday gift vouchers

### 2. **Product Management** 📦
- Add/Update products
- Manage product categories
- Manage manufacturers
- Track inventory

### 3. **Inventory Management** 🏪
- Import goods from suppliers
- Automatic ordering when inventory is low
- Check maximum product quantity (SLSPTD)
- Manage import/order documents

### 4. **Promotion System** 🎁
- **Flash Sale**: Discount on specific products
- **Combo**: Buy two products with discount
- **Member**: Promotion by membership level
- Monitor promotion quantity & duration

### 5. **Order Processing** 📋
- Add products to shopping carts
- Calculate and apply discounts
- Create invoices
- Payment & statistics

### 6. **Analytics & Reports** 📊
- Customer purchase statistics by date
- Daily product sales list
- Daily total revenue calculation
- Detailed customer analysis

---

## 🗄️ Database

### Database Name
```
QLST (Supermarket Management System)
```

### Main Tables

| Table | Description |
|-------|-------------|
| `PHAN_LOAI` | Customer classification (VIP level) |
| `KHACH_HANG` | Customer information |
| `DANH_MUC` | Product categories |
| `NHA_SAN_XUAT` | Manufacturers |
| `SAN_PHAM` | Products |
| `PHIEU_MUA_SAM` | Shopping receipts |
| `CHI_TIET_PHIEU_MUA_SAM` | Shopping receipt details |
| `HOA_DON` | Invoices |
| `CHI_TIET_HOA_DON` | Invoice details |
| `KHUYEN_MAI` | Promotion programs |
| `CHI_TIET_KHUYEN_MAI_*` | Promotion details (Flash, Combo, Member) |
| `PHIEU_DAT_HANG` | Purchase orders |
| `PHIEU_NHAN_HANG` | Goods receipt notes |

---

## 🚀 Usage Guide

### Step 1: Create Database

```sql
-- Run scriptST.sql to create database & schema
USE master
GO
-- Execute content from: 01_Database_Schema/scriptST.sql
```

### Step 2: Define Custom Types

```sql
-- Run bang_phu.sql to define custom types
-- Execute content from: 01_Database_Schema/bang_phu.sql
```

### Step 3: Create Stored Procedures

```sql
-- Run files sequentially from 02_Stored_Procedures folder
-- Recommended order:
1. 02_Stored_Procedures/01_Customer_Management/
2. 02_Stored_Procedures/02_Product_Management/
3. 02_Stored_Procedures/03_Inventory_Management/
4. 02_Stored_Procedures/04_Promotion_Management/
5. 02_Stored_Procedures/05_Business_Analytics/
6. 02_Stored_Procedures/06_Order_Processing/
```

### Step 4: Initialize Data

```sql
-- Run data.sql to add sample data
-- Execute content from: 03_Data_Initialization/data.sql
```

### Step 5: Verification

```sql
-- Check database creation
USE QLST
GO

-- List all tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'
GO

-- Check stored procedures
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE'
GO
```

---

## 📐 Code Conventions

### Naming Conventions

#### Tables
- **Rule:** `SANG_PHAM` (UPPERCASE, separated by `_`)
- **Examples:** `KHACH_HANG`, `CHI_TIET_HOA_DON`, `DANH_MUC`

#### Columns
- **Rule:** `MaSanPham` or `Ma_San_Pham` (CamelCase or Snake_case)
- **Examples:** `MaKhachHang`, `HoTen`, `SoLuongTonKho`

#### Stored Procedures
- **Rule:** Vietnamese or English, starting with action verb
- **Examples:** 
  - `ThemSanPham` (add)
  - `CapNhatThongTinKhachHang` (update)
  - `XoaDanhMucSanPham` (delete)
  - `sp_LayDanhSachKhachHang` (get list)

#### Constraints
- **Primary Key:** `PK_<TABLE>`
- **Foreign Key:** `FK_<TABLE1>_<TABLE2>`
- **Unique:** `UQ_<TABLE>_<COLUMN>`
- **Check:** `CK_<TABLE>_<COLUMN>`
- **Default:** `DF_<TABLE>_<COLUMN>`

### Transaction Isolation Levels

```sql
-- Read Committed (Default)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- Repeatable Read (To avoid Phantom Reads)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

-- Serializable (Highest level, most restrictive)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
```

### Lock Hints

```sql
-- UPDLOCK: Update lock when checking conditions
WITH (UPDLOCK, HOLDLOCK)

-- XLOCK: Exclusive lock for insert/update
WITH (XLOCK)

-- ROWLOCK: Lock at row level
WITH (ROWLOCK)

-- READCOMMITTED: Read only committed data
WITH (READCOMMITTED)
```

### Error Handling

```sql
BEGIN TRAN
BEGIN TRY
    -- Main logic
    COMMIT TRAN
    PRINT N'Success'
END TRY
BEGIN CATCH
    ROLLBACK TRAN
    THROW
END CATCH
```

---

## 🔐 Data Security

### Soft Delete
Tables use `DaXoa BIT DEFAULT 0` column to mark soft delete instead of physical deletion.

```sql
-- Instead of DELETE, use:
UPDATE SAN_PHAM SET DaXoa = 1 WHERE MaSanPham = @MaSanPham

-- When SELECT, add condition:
SELECT * FROM SAN_PHAM WHERE DaXoa = 0
```

### Transaction Management
All critical operations are wrapped in transactions to ensure ACID properties.

---

## 🧪 Testing & Validation

### Data Integrity Check
```sql
-- Check data integrity
DBCC CHECKDB (QLST)

-- Check foreign key constraints
SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS

-- Check sample data
SELECT COUNT(*) FROM KHACH_HANG
SELECT COUNT(*) FROM SAN_PHAM
SELECT COUNT(*) FROM HOA_DON
```

---

## 📝 References

- **SQL Server Documentation:** https://docs.microsoft.com/en-us/sql/
- **Transaction Isolation Levels:** https://learn.microsoft.com/en-us/sql/t-sql/statements/set-transaction-isolation-level-transact-sql
- **Stored Procedures Best Practices:** https://learn.microsoft.com/en-us/sql/t-sql/statements/create-procedure-transact-sql

---

## 👥 Team Members - Group 7

| Role | Name | Notes |
|------|------|-------|
| Team Lead | ... | ... |
| Developer | ... | ... |
| Database Designer | ... | ... |
| Tester | ... | ... |

---

## 📅 Update History

| Version | Date | Content |
|---------|------|---------|
| v1.0 | 2024-12 | Initial version |
| v1.1 | 2025-03 | Reorganized directory structure |
| v1.2 | 2025-03 | Added documentation |

---

## 📞 Contact & Support

If you have any questions or issues, please contact the team via:
- **Email:** group7@university.edu
- **Classroom:** [Google Classroom Link]

---

## 📄 License

This project is developed for educational purposes.

---

**Last Updated:** 26/03/2025
