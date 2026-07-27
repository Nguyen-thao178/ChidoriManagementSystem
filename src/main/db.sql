CREATE DATABASE CafeDB;
GO
USE CafeDB;
GO

CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) UNIQUE NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    fullname NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    role NVARCHAR(20) DEFAULT 'customer'
);

CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    description NVARCHAR(500),
    stock INT NOT NULL DEFAULT 0,
    sold_count INT NOT NULL DEFAULT 0,
    image_url NVARCHAR(255),
    category NVARCHAR(50)
);

CREATE TABLE orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES users(id),
    order_date DATETIME DEFAULT GETDATE(),
    total_amount DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending'
);

CREATE TABLE order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES orders(id),
    product_id INT FOREIGN KEY REFERENCES products(id),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Bảng khuyến mãi (chỉ hiển thị cho thành viên)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='promotions' AND xtype='U')
CREATE TABLE promotions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(500),
    discount_percent INT NOT NULL,      -- phần trăm giảm giá (0-100)
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    image_url NVARCHAR(255),
    status NVARCHAR(20) DEFAULT 'active'
);

-- Bảng liên hệ (nhân viên, quản lý, chủ quán, nhà cung cấp)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='contacts' AND xtype='U')
CREATE TABLE contacts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    position NVARCHAR(50) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100),
    address NVARCHAR(255),
    notes NVARCHAR(500)
);

-- Bảng khuyến mãi đặc biệt cho từng sản phẩm (card item)
CREATE TABLE promotion_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL FOREIGN KEY REFERENCES products(id),
    discount_percent INT NOT NULL,   -- % giảm giá riêng cho sản phẩm này
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status NVARCHAR(20) DEFAULT 'active'
);

-- Chèn một vài sản phẩm khuyến mãi đặc biệt (ví dụ: cà phê đen giảm 30%, matcha latte giảm 25%)
INSERT INTO promotion_items (product_id, discount_percent, start_date, end_date) VALUES
(1, 30, '2025-06-01', '2025-12-31'),
(4, 25, '2025-06-01', '2025-12-31');

-- Chèn các chương trình khuyến mãi mới
INSERT INTO promotions (title, description, discount_percent, start_date, end_date, image_url, status) VALUES
(N'Giảm 20% toàn bộ cà phê', N'Áp dụng cho mọi đơn hàng từ 2 sản phẩm', 20, '2025-06-01', '2025-12-31', 'https://picsum.photos/id/12/300/200', 'active'),
(N'Giảm 15% cho trà sữa', N'Dành cho thành viên VIP', 15, '2025-06-10', '2025-07-10', 'https://picsum.photos/id/13/300/200', 'active'),
(N'Mua 1 tặng 1 bánh ngọt', N'Tặng bánh khi mua bất kỳ đồ uống nào', 50, '2025-06-15', '2025-06-30', 'https://picsum.photos/id/14/300/200', 'active');

-- Thêm dữ liệu mẫu liên hệ
INSERT INTO contacts (name, position, phone, email, address, notes) VALUES
(N'Trần Văn A', N'owner', N'0909123456', N'owner@chidori.com', N'123 Đường Cà Phê, Quận 1', N'Chủ quán - sáng lập'),
(N'Lê Thị B', N'manager', N'0918234567', N'manager@chidori.com', N'123 Đường Cà Phê, Quận 1', N'Quản lý điều hành'),
(N'Nguyễn Văn C', N'employee', N'0933345678', N'barista1@chidori.com', NULL, N'Barista chính'),
(N'Phạm Thị D', N'employee', N'0944456789', N'server1@chidori.com', NULL, N'Nhân viên phục vụ'),
(N'Công ty Cà phê Xanh', N'supplier', N'0281234567', N'sales@xanhcoffee.com', N'456 Đường Cầu Giấy, Hà Nội', N'Nhà cung cấp hạt cà phê'),
(N'Trang trại Đắk Lắk', N'supplier', N'0262123456', N'farm@daklak.com', N'Buôn Ma Thuột', N'Cung cấp cà phê đặc sản');

-- Insert sample products
INSERT INTO products (name, price, description, stock, sold_count, image_url, category) VALUES
(N'Cà phê đen', 25000, N'Cà phê nguyên chất đậm đà', 100, 250, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400', 'Coffee'),
(N'Bạc sỉu', 30000, N'Sữa đặc + cà phê nhẹ', 80, 189, 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=400', 'Coffee'),
(N'Cappuccino', 45000, N'Espresso + sữa bọt', 60, 135, 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400', 'Coffee'),
(N'Matcha Latte', 50000, N'Trà xanh Nhật Bản', 50, 142, 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400', 'Tea'),
(N'Bánh ngọt', 35000, N'Bánh kem tươi', 40, 98, 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400', 'Pastry'),
(N'Sữa chua cà phê', 40000, N'Sữa chua đông lạnh', 70, 76, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 'Coffee');

INSERT INTO users (username, password_hash, fullname, email, role) VALUES
('staff1', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Nguyễn Văn Nhân Viên', 'staff1@chidori.com', 'staff'),
('staff2', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Trần Thị Phục Vụ', 'staff2@chidori.com', 'staff');

-- Chèn sản phẩm mới với số lượng đã bán khác nhau
INSERT INTO products (name, price, description, stock, sold_count, image_url, category) VALUES
(N'Cà phê đen', 25000, N'Cà phê nguyên chất đậm đà, rang xay từ hạt Arabica', 50, 250, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400', 'Coffee'),
(N'Bạc sỉu', 30000, N'Sữa đặc hoà quyện cùng cà phê nhẹ, thơm béo', 40, 189, 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?w=400', 'Coffee'),
(N'Cappuccino', 45000, N'Espresso kết hợp sữa tươi và lớp bọt sữa mịn', 30, 135, 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400', 'Coffee'),
(N'Matcha Latte', 50000, N'Trà xanh Nhật Bản hòa cùng sữa tươi', 25, 142, 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=400', 'Tea'),
(N'Bánh ngọt', 35000, N'Bánh kem tươi, nhiều vị: socola, dâu, matcha', 20, 98, 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400', 'Pastry'),
(N'Sữa chua cà phê', 40000, N'Sữa chua đông lạnh pha cà phê espresso', 35, 76, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 'Coffee');

INSERT INTO promotions (title, description, discount_percent, start_date, end_date, image_url) VALUES
(N'Giảm 20% cho cà phê', N'Áp dụng cho tất cả đồ uống cà phê', 20, '2025-06-01', '2025-12-31', 'https://picsum.photos/id/12/300/200'),
(N'Giảm 10% toàn bộ menu', N'Dành cho thành viên', 10, '2025-06-01', '2025-12-31', 'https://picsum.photos/id/13/300/200');

-- Thêm cột role vào bảng users (nếu chưa có)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name='role' AND object_id = OBJECT_ID('users'))
ALTER TABLE users ADD role NVARCHAR(20) DEFAULT 'staff';

-- Bảng điểm tích lũy (cho khách hàng thành viên)
CREATE TABLE loyalty_points (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL FOREIGN KEY REFERENCES users(id),
    points INT NOT NULL DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    updated_at DATETIME DEFAULT GETDATE()
);

-- Bảng cài đặt hệ thống
CREATE TABLE system_settings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key NVARCHAR(100) UNIQUE NOT NULL,
    setting_value NVARCHAR(500),
    description NVARCHAR(255)
);

-- Chèn dữ liệu mẫu
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('company_name', 'Chidori Coffee', N'Tên công ty'),
('tax_rate', '10', N'Thuế VAT (%)'),
('loyalty_rate', '5', N'Điểm tích lũy (1 điểm / 1.000đ)');

-- Thêm tài khoản admin (mật khẩu: admin123)
INSERT INTO users (username, password_hash, fullname, email, role) VALUES
('admin', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Quản trị viên', 'admin@chidori.com', 'admin');

-- Cập nhật role cho nhân viên cũ
UPDATE users SET role='staff' WHERE role IS NULL;

-- Nếu chưa có cột role, thêm vào
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name='role' AND object_id = OBJECT_ID('users'))
ALTER TABLE users ADD role NVARCHAR(20) DEFAULT 'staff';

-- Xóa admin cũ nếu tồn tại
DELETE FROM users WHERE username = 'admin';

-- Chèn admin mới (mật khẩu 'admin123' đã hash)
-- Hash của 'admin123' là 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
INSERT INTO users (username, password_hash, fullname, email, role)
VALUES ('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', N'Quản trị viên', 'admin@chidori.com', 'admin');