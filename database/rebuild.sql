/*
===============================================================================
 CHIDORI COFFEE MANAGEMENT SYSTEM - FULL SQL SERVER REBUILD
===============================================================================
 Thứ tự:
   1. Delete database
   2. Create database
   3. Tables + foreign keys + indexes
   4. Stored procedures
   5. Triggers
   6. Views
   7. Insert seed data

 CẢNH BÁO:
   Script này XÓA TOÀN BỘ CafeDB và mọi dữ liệu hiện có.
   Chỉ chạy khi muốn khởi tạo lại database từ đầu.
===============================================================================
*/

USE master;
GO

IF DB_ID(N'CafeDB') IS NOT NULL
BEGIN
    ALTER DATABASE CafeDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CafeDB;
END;
GO

CREATE DATABASE CafeDB;
GO

USE CafeDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

CREATE TABLE dbo.users (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    username      VARCHAR(50) NOT NULL,
    password_hash CHAR(64) NOT NULL,
    fullname      NVARCHAR(120) NOT NULL,
    email         VARCHAR(254) NOT NULL,
    role          VARCHAR(20) NOT NULL CONSTRAINT DF_users_role DEFAULT 'member',
    created_at    DATETIME2 NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
    CONSTRAINT UX_users_username UNIQUE (username),
    CONSTRAINT UX_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('admin', 'member', 'staff'))
);

CREATE TABLE dbo.products (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(150) NOT NULL,
    price       DECIMAL(18,2) NOT NULL,
    description NVARCHAR(1000) NULL,
    stock       INT NOT NULL CONSTRAINT DF_products_stock DEFAULT 0,
    sold_count  INT NOT NULL CONSTRAINT DF_products_sold_count DEFAULT 0,
    image_url   NVARCHAR(1000) NULL,
    category    NVARCHAR(80) NOT NULL,
    barcode     VARCHAR(64) NULL,
    created_at  DATETIME2 NOT NULL CONSTRAINT DF_products_created_at DEFAULT SYSDATETIME(),
    updated_at  DATETIME2 NOT NULL CONSTRAINT DF_products_updated_at DEFAULT SYSDATETIME(),
    CONSTRAINT CK_products_price CHECK (price >= 0),
    CONSTRAINT CK_products_stock CHECK (stock >= 0),
    CONSTRAINT CK_products_sold_count CHECK (sold_count >= 0),
    CONSTRAINT CK_products_barcode CHECK (
        barcode IS NULL OR (
            LEN(barcode) = 13
            AND barcode NOT LIKE '%[^0-9]%'
        )
    )
);

CREATE UNIQUE INDEX UX_products_barcode
    ON dbo.products(barcode)
    WHERE barcode IS NOT NULL;

CREATE TABLE dbo.promotions (
    id               INT IDENTITY(1,1) PRIMARY KEY,
    created_by_user_id INT NULL,
    title            NVARCHAR(150) NOT NULL,
    description      NVARCHAR(1000) NULL,
    discount_percent INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    image_url        NVARCHAR(1000) NULL,
    status           VARCHAR(20) NOT NULL CONSTRAINT DF_promotions_status DEFAULT 'active',
    CONSTRAINT FK_promotions_created_by
        FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_promotions_discount CHECK (discount_percent BETWEEN 0 AND 100),
    CONSTRAINT CK_promotions_dates CHECK (end_date >= start_date),
    CONSTRAINT CK_promotions_status CHECK (status IN ('active', 'inactive'))
);

CREATE TABLE dbo.promotion_items (
    id               INT IDENTITY(1,1) PRIMARY KEY,
    promotion_id     INT NOT NULL,
    product_id       INT NOT NULL,
    discount_percent INT NOT NULL,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    status           VARCHAR(20) NOT NULL CONSTRAINT DF_promotion_items_status DEFAULT 'active',
    CONSTRAINT FK_promotion_items_promotion
        FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(id) ON DELETE CASCADE,
    CONSTRAINT FK_promotion_items_product
        FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE,
    CONSTRAINT CK_promotion_items_discount CHECK (discount_percent BETWEEN 0 AND 100),
    CONSTRAINT CK_promotion_items_dates CHECK (end_date >= start_date),
    CONSTRAINT CK_promotion_items_status CHECK (status IN ('active', 'inactive'))
);

CREATE TABLE dbo.orders (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    user_id      INT NOT NULL,
    order_date   DATETIME2 NOT NULL CONSTRAINT DF_orders_order_date DEFAULT SYSDATETIME(),
    total_amount DECIMAL(18,2) NOT NULL,
    status       VARCHAR(30) NOT NULL CONSTRAINT DF_orders_status DEFAULT 'pending',
    order_type VARCHAR(20) NOT NULL CONSTRAINT DF_orders_order_type DEFAULT 'direct',
    payment_method VARCHAR(20) NOT NULL CONSTRAINT DF_orders_payment_method DEFAULT 'cash',
    deposit_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_orders_deposit_amount DEFAULT 0,
    pickup_date DATE NULL,
    pickup_status VARCHAR(20) NULL,
    completed_at DATETIME2 NULL,
    cancelled_at DATETIME2 NULL,
    cancellation_reason NVARCHAR(300) NULL,
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_orders_total CHECK (total_amount >= 0),
    CONSTRAINT CK_orders_status CHECK (
        status IN ('pending', 'completed', 'deposit_pending', 'picked_up', 'no_show', 'cancelled', 'refunded')
    ),
    CONSTRAINT CK_orders_type CHECK (order_type IN ('direct', 'deposit')),
    CONSTRAINT CK_orders_payment_method CHECK (payment_method IN ('cash', 'vnpay')),
    CONSTRAINT CK_orders_deposit_amount CHECK (deposit_amount >= 0 AND deposit_amount <= total_amount),
    CONSTRAINT CK_orders_pickup_status CHECK (
        pickup_status IS NULL OR pickup_status IN ('pending', 'picked_up', 'no_show')
    ),
    CONSTRAINT CK_orders_deposit_fields CHECK (
        (order_type = 'direct' AND pickup_date IS NULL AND deposit_amount = 0)
        OR
        (order_type = 'deposit' AND pickup_date IS NOT NULL AND deposit_amount > 0)
    )
);

CREATE TABLE dbo.order_items (
    id         INT IDENTITY(1,1) PRIMARY KEY,
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL,
    price      DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_order_items_order
        FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT CK_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_items_price CHECK (price >= 0)
);

CREATE TABLE dbo.payments (
    id                    BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id              INT NOT NULL,
    payment_stage         VARCHAR(20) NOT NULL,
    payment_method        VARCHAR(20) NOT NULL,
    amount                DECIMAL(18,2) NOT NULL,
    status                VARCHAR(20) NOT NULL CONSTRAINT DF_payments_status DEFAULT 'paid',
    transaction_reference VARCHAR(150) NULL,
    paid_at               DATETIME2 NULL,
    created_at            DATETIME2 NOT NULL CONSTRAINT DF_payments_created_at DEFAULT SYSDATETIME(),
    CONSTRAINT FK_payments_order
        FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT CK_payments_stage
        CHECK (payment_stage IN ('full', 'deposit', 'balance', 'refund')),
    CONSTRAINT CK_payments_method CHECK (payment_method IN ('cash', 'vnpay')),
    CONSTRAINT CK_payments_amount CHECK (amount >= 0),
    CONSTRAINT CK_payments_status CHECK (status IN ('pending', 'paid', 'failed', 'refunded'))
);

CREATE TABLE dbo.order_status_history (
    id            BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id      INT NOT NULL,
    old_status    VARCHAR(30) NULL,
    new_status    VARCHAR(30) NOT NULL,
    note          NVARCHAR(300) NULL,
    changed_at    DATETIME2 NOT NULL CONSTRAINT DF_order_history_changed_at DEFAULT SYSDATETIME(),
    changed_by_id INT NULL,
    CONSTRAINT FK_order_history_order
        FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_history_user
        FOREIGN KEY (changed_by_id) REFERENCES dbo.users(id)
);

CREATE TABLE dbo.loyalty_points (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    user_id     INT NOT NULL,
    points      INT NOT NULL CONSTRAINT DF_loyalty_points_points DEFAULT 0,
    total_spent DECIMAL(18,2) NOT NULL CONSTRAINT DF_loyalty_points_spent DEFAULT 0,
    updated_at  DATETIME2 NOT NULL CONSTRAINT DF_loyalty_points_updated DEFAULT SYSDATETIME(),
    CONSTRAINT UX_loyalty_points_user UNIQUE (user_id),
    CONSTRAINT FK_loyalty_points_user
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
    CONSTRAINT CK_loyalty_points_points CHECK (points >= 0),
    CONSTRAINT CK_loyalty_points_spent CHECK (total_spent >= 0)
);

CREATE TABLE dbo.contacts (
    id       INT IDENTITY(1,1) PRIMARY KEY,
    user_id  INT NULL,
    name     NVARCHAR(120) NOT NULL,
    position VARCHAR(30) NOT NULL,
    phone    VARCHAR(30) NULL,
    email    VARCHAR(254) NULL,
    address  NVARCHAR(500) NULL,
    notes    NVARCHAR(1000) NULL,
    CONSTRAINT FK_contacts_user
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE SET NULL,
    CONSTRAINT CK_contacts_position CHECK (position IN ('owner', 'manager', 'employee', 'other'))
);

CREATE TABLE dbo.system_settings (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    updated_by_user_id INT NULL,
    setting_key   VARCHAR(100) NOT NULL,
    setting_value NVARCHAR(2000) NULL,
    description   NVARCHAR(500) NULL,
    CONSTRAINT FK_system_settings_updated_by
        FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id),
    CONSTRAINT UX_system_settings_key UNIQUE (setting_key)
);
GO

CREATE INDEX IX_orders_user_date ON dbo.orders(user_id, order_date DESC);
CREATE INDEX IX_orders_pending_deposits
    ON dbo.orders(status, pickup_date)
    INCLUDE (user_id, deposit_amount)
    WHERE order_type = 'deposit';
CREATE INDEX IX_order_items_product ON dbo.order_items(product_id);
CREATE INDEX IX_payments_order_date ON dbo.payments(order_id, created_at DESC);
CREATE INDEX IX_order_history_order_date
    ON dbo.order_status_history(order_id, changed_at DESC);
CREATE INDEX IX_promotion_items_product_dates
    ON dbo.promotion_items(product_id, status, start_date, end_date);
CREATE INDEX IX_promotion_items_promotion_product
    ON dbo.promotion_items(promotion_id, product_id);
GO

CREATE OR ALTER PROCEDURE dbo.usp_products_find_by_barcode
    @barcode VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @normalized_barcode VARCHAR(64) = NULLIF(LTRIM(RTRIM(@barcode)), '');

    SELECT
        id,
        name,
        price,
        description,
        stock,
        sold_count,
        image_url,
        category,
        barcode
    FROM dbo.products
    WHERE barcode = @normalized_barcode;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_products_set_barcode
    @product_id INT,
    @barcode VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @normalized_barcode VARCHAR(64) = NULLIF(LTRIM(RTRIM(@barcode)), '');

    IF NOT EXISTS (SELECT 1 FROM dbo.products WHERE id = @product_id)
        THROW 51002, 'Product does not exist.', 1;

    IF @normalized_barcode IS NOT NULL
       AND (
           LEN(@normalized_barcode) <> 13
           OR @normalized_barcode LIKE '%[^0-9]%'
       )
        THROW 51003, 'EAN-13 barcode must contain exactly 13 digits.', 1;

    IF @normalized_barcode IS NOT NULL
       AND EXISTS (
           SELECT 1
           FROM dbo.products
           WHERE barcode = @normalized_barcode
             AND id <> @product_id
       )
        THROW 51004, 'Barcode is already assigned to another product.', 1;

    UPDATE dbo.products
    SET barcode = @normalized_barcode
    WHERE id = @product_id;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_inventory_adjust_stock
    @product_id INT,
    @quantity_change INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE dbo.products
    SET stock = stock + @quantity_change
    WHERE id = @product_id
      AND stock + @quantity_change >= 0;

    IF @@ROWCOUNT = 0
        THROW 51005, 'Product does not exist or stock would become negative.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_expire_overdue_deposits
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    DECLARE @expired_orders TABLE (order_id INT PRIMARY KEY);

    UPDATE dbo.orders WITH (UPDLOCK, READPAST, ROWLOCK)
    SET status = 'no_show',
        pickup_status = 'no_show',
        cancelled_at = SYSDATETIME(),
        cancellation_reason = N'Không nhận hàng'
    OUTPUT inserted.id INTO @expired_orders(order_id)
    WHERE order_type = 'deposit'
      AND status = 'deposit_pending'
      AND pickup_date < CAST(GETDATE() AS DATE);

    UPDATE p
    SET stock = stock + expired.quantity
    FROM dbo.products p
    INNER JOIN (
        SELECT oi.product_id, SUM(oi.quantity) AS quantity
        FROM dbo.order_items oi
        INNER JOIN @expired_orders eo ON eo.order_id = oi.order_id
        GROUP BY oi.product_id
    ) expired ON expired.product_id = p.id;

    DECLARE @expired_count INT = (SELECT COUNT(*) FROM @expired_orders);
    COMMIT TRANSACTION;
    SELECT @expired_count AS expired_count;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_users_create_loyalty_account
ON dbo.users
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.loyalty_points (user_id, points, total_spent)
    SELECT i.id, 0, 0
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.loyalty_points lp
        WHERE lp.user_id = i.id
    );
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_products_set_updated_at
ON dbo.products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(updated_at)
        RETURN;

    UPDATE p
    SET updated_at = SYSDATETIME()
    FROM dbo.products p
    INNER JOIN inserted i ON i.id = p.id;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_order_items_validate_stock
ON dbo.order_items
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT product_id, SUM(quantity) AS requested_quantity
            FROM inserted
            GROUP BY product_id
        ) requested
        INNER JOIN dbo.products p ON p.id = requested.product_id
        WHERE requested.requested_quantity > p.stock
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51006, 'Order quantity exceeds available product stock.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_orders_create_payment_and_history
ON dbo.orders
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.payments
        (order_id, payment_stage, payment_method, amount, status, paid_at)
    SELECT
        i.id,
        CASE WHEN i.order_type = 'deposit' THEN 'deposit' ELSE 'full' END,
        i.payment_method,
        CASE WHEN i.order_type = 'deposit' THEN i.deposit_amount ELSE i.total_amount END,
        CASE WHEN i.status = 'pending' THEN 'pending' ELSE 'paid' END,
        CASE WHEN i.status = 'pending' THEN NULL ELSE SYSDATETIME() END
    FROM inserted i;

    INSERT INTO dbo.order_status_history (order_id, old_status, new_status, note)
    SELECT i.id, NULL, i.status, N'Tạo đơn hàng'
    FROM inserted i;
END;
GO

CREATE OR ALTER TRIGGER dbo.trg_orders_track_status
ON dbo.orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.order_status_history (order_id, old_status, new_status, note)
    SELECT
        i.id,
        d.status,
        i.status,
        CASE
            WHEN i.status = 'picked_up' THEN N'Khách đã nhận hàng'
            WHEN i.status = 'no_show' THEN N'Khách không nhận hàng'
            WHEN i.status = 'cancelled' THEN COALESCE(i.cancellation_reason, N'Đã hủy')
            ELSE N'Cập nhật trạng thái'
        END
    FROM inserted i
    INNER JOIN deleted d ON d.id = i.id
    WHERE i.status <> d.status;

    INSERT INTO dbo.payments
        (order_id, payment_stage, payment_method, amount, status, paid_at)
    SELECT
        i.id,
        'balance',
        i.payment_method,
        i.total_amount - i.deposit_amount,
        'paid',
        SYSDATETIME()
    FROM inserted i
    INNER JOIN deleted d ON d.id = i.id
    WHERE i.order_type = 'deposit'
      AND d.status = 'deposit_pending'
      AND i.status = 'picked_up'
      AND i.total_amount > i.deposit_amount
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.payments p
          WHERE p.order_id = i.id
            AND p.payment_stage = 'balance'
            AND p.status = 'paid'
      );
END;
GO

CREATE OR ALTER VIEW dbo.vw_product_barcode_catalog
AS
    SELECT
        p.id,
        p.barcode,
        p.name,
        p.category,
        p.price,
        p.stock,
        p.sold_count,
        p.image_url,
        COALESCE(item_discount.discount_percent, global_discount.discount_percent, 0)
            AS discount_percent,
        CAST(
            p.price * (
                100 - COALESCE(
                    item_discount.discount_percent,
                    global_discount.discount_percent,
                    0
                )
            ) / 100.0
            AS DECIMAL(18,2)
        ) AS effective_price
    FROM dbo.products p
    OUTER APPLY (
        SELECT TOP (1) pi.discount_percent
        FROM dbo.promotion_items pi
        WHERE pi.product_id = p.id
          AND pi.status = 'active'
          AND CAST(GETDATE() AS DATE) BETWEEN pi.start_date AND pi.end_date
        ORDER BY pi.discount_percent DESC, pi.id DESC
    ) item_discount
    OUTER APPLY (
        SELECT TOP (1) pr.discount_percent
        FROM dbo.promotions pr
        WHERE pr.status = 'active'
          AND CAST(GETDATE() AS DATE) BETWEEN pr.start_date AND pr.end_date
        ORDER BY pr.discount_percent DESC, pr.id DESC
    ) global_discount;
GO

CREATE OR ALTER VIEW dbo.vw_inventory_status
AS
    SELECT
        id,
        barcode,
        name,
        category,
        stock,
        sold_count,
        CASE
            WHEN stock = 0 THEN 'out_of_stock'
            WHEN stock <= 10 THEN 'low_stock'
            ELSE 'in_stock'
        END AS inventory_status,
        updated_at
    FROM dbo.products;
GO

CREATE OR ALTER VIEW dbo.vw_order_summary
AS
    SELECT
        o.id AS order_id,
        o.user_id,
        u.username,
        u.fullname,
        o.order_date,
        o.status,
        o.total_amount,
        o.order_type,
        o.payment_method,
        o.deposit_amount,
        o.pickup_date,
        o.pickup_status,
        CASE
            WHEN o.order_type = 'direct' THEN N'Thanh toán trực tiếp'
            WHEN o.status = 'no_show' THEN N'Đã cọc nhưng không nhận hàng'
            WHEN o.status = 'picked_up' THEN N'Đã cọc và đã nhận hàng'
            ELSE N'Đã cọc - Chờ nhận hàng'
        END AS transaction_tag,
        COUNT(oi.id) AS line_count,
        COALESCE(SUM(oi.quantity), 0) AS item_count,
        COALESCE(MAX(pay.amount), 0) AS paid_amount
    FROM dbo.orders o
    INNER JOIN dbo.users u ON u.id = o.user_id
    LEFT JOIN dbo.order_items oi ON oi.order_id = o.id
    LEFT JOIN (
        SELECT order_id, SUM(amount) AS amount
        FROM dbo.payments
        WHERE status = 'paid'
        GROUP BY order_id
    ) pay ON pay.order_id = o.id
    GROUP BY
        o.id,
        o.user_id,
        u.username,
        u.fullname,
        o.order_date,
        o.status,
        o.total_amount,
        o.order_type,
        o.payment_method,
        o.deposit_amount,
        o.pickup_date,
        o.pickup_status;
GO

CREATE OR ALTER VIEW dbo.vw_deposit_order_calendar
AS
    SELECT
        o.id AS order_id,
        o.user_id,
        u.fullname,
        o.order_date,
        o.pickup_date,
        o.total_amount,
        o.deposit_amount,
        o.payment_method,
        o.status,
        o.pickup_status,
        CASE
            WHEN o.status = 'no_show' THEN N'Đã cọc nhưng không nhận hàng'
            WHEN o.status = 'picked_up' THEN N'Đã cọc và đã nhận hàng'
            ELSE N'Đã cọc - Chờ nhận hàng'
        END AS transaction_tag
    FROM dbo.orders o
    INNER JOIN dbo.users u ON u.id = o.user_id
    WHERE o.order_type = 'deposit';
GO

/*
  Development account:
    username: admin
    password: admin123
  Change this password immediately after first login.
*/
INSERT INTO dbo.users (username, password_hash, fullname, email, role)
VALUES (
    'admin',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',
    N'Chidori Administrator',
    'admin@chidori.local',
    'admin'
);

/*
  These are development barcodes. Replace them with the codes printed on
  the products in your shop. Values are strings to preserve leading zeroes.
*/
INSERT INTO dbo.products
    (name, price, description, stock, sold_count, image_url, category, barcode)
VALUES
    (N'Cà phê sữa', 35000, N'Cà phê rang xay với sữa đặc.', 100, 0, NULL, N'Coffee', '8938501434012'),
    (N'Cà phê đen', 30000, N'Cà phê đen truyền thống.', 100, 0, NULL, N'Coffee', '8938501434029'),
    (N'Trà đào', 45000, N'Trà đào thanh mát.', 80, 0, NULL, N'Tea', '8938501434036'),
    (N'Bánh sừng bò', 28000, N'Bánh bơ nướng trong ngày.', 40, 0, NULL, N'Pastry', '8938501434043');

INSERT INTO dbo.system_settings
    (updated_by_user_id, setting_key, setting_value, description)
VALUES
    ((SELECT id FROM dbo.users WHERE username = 'admin'),
     'store_name', N'Chidori Coffee', N'Tên cửa hàng'),
    ((SELECT id FROM dbo.users WHERE username = 'admin'),
     'currency', 'VND', N'Đơn vị tiền tệ'),
    ((SELECT id FROM dbo.users WHERE username = 'admin'),
     'barcode_scanner_enabled', 'true', N'Cho phép thêm sản phẩm bằng máy quét mã vạch'),
    ((SELECT id FROM dbo.users WHERE username = 'admin'),
     'deposit_percent', '30', N'Phần trăm tiền cọc mặc định');
GO

INSERT INTO dbo.contacts (user_id, name, position, phone, email, address, notes)
VALUES
    ((SELECT id FROM dbo.users WHERE username = 'admin'),
     N'Chidori Administrator', 'manager', '19001234',
     'admin@chidori.local', N'123 Đường Cà Phê, Quận 1, TP.HCM',
     N'Tài khoản quản trị hệ thống'),
    (NULL, N'Chidori Owner', 'owner', '0900000001',
     'owner@chidori.local', N'Hồ Chí Minh', N'Chủ cửa hàng');
GO

INSERT INTO dbo.promotions
    (created_by_user_id, title, description, discount_percent,
     start_date, end_date, image_url, status)
VALUES
    (
        (SELECT id FROM dbo.users WHERE username = 'admin'),
        N'Ưu đãi khai trương',
        N'Giảm 10% toàn bộ sản phẩm trong thời gian khuyến mãi.',
        10,
        CAST(GETDATE() AS DATE),
        DATEADD(DAY, 30, CAST(GETDATE() AS DATE)),
        NULL,
        'active'
    );
GO

INSERT INTO dbo.promotion_items
    (promotion_id, product_id, discount_percent, start_date, end_date, status)
SELECT
    pr.id,
    p.id,
    pr.discount_percent,
    pr.start_date,
    pr.end_date,
    'active'
FROM dbo.promotions pr
CROSS JOIN dbo.products p
WHERE pr.title = N'Ưu đãi khai trương';
GO

-- A valid barcode must resolve to one and only one product.
IF EXISTS (
    SELECT barcode
    FROM dbo.products
    WHERE barcode IS NOT NULL
    GROUP BY barcode
    HAVING COUNT(*) <> 1
)
BEGIN
    THROW 51001, 'Invalid barcode catalog: a barcode must identify exactly one product.', 1;
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.products
    WHERE name = N'Cà phê sữa' AND barcode = '8938501434012'
)
    THROW 51011, 'Seed barcode mismatch: Cà phê sữa.', 1;

IF NOT EXISTS (
    SELECT 1 FROM dbo.products
    WHERE name = N'Cà phê đen' AND barcode = '8938501434029'
)
    THROW 51012, 'Seed barcode mismatch: Cà phê đen.', 1;

IF NOT EXISTS (
    SELECT 1 FROM dbo.products
    WHERE name = N'Trà đào' AND barcode = '8938501434036'
)
    THROW 51013, 'Seed barcode mismatch: Trà đào.', 1;

IF NOT EXISTS (
    SELECT 1 FROM dbo.products
    WHERE name = N'Bánh sừng bò' AND barcode = '8938501434043'
)
    THROW 51014, 'Seed barcode mismatch: Bánh sừng bò.', 1;
GO

PRINT N'CafeDB đã được tạo lại thành công.';
PRINT N'4 barcode EAN-13 đã được giữ nguyên và xác minh.';
GO
