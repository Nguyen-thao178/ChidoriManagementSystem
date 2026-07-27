/*
  Chidori Coffee - repair the live order schema and complete the relational ERD.

  This migration is idempotent and preserves existing data. It:
    1. Adds the direct/deposit checkout columns expected by OrderDAO.
    2. Connects promotions to products through promotion_items.
    3. Adds optional ownership/audit relations for contacts, promotions and settings.
    4. Adds normalized payment and order-status history tables.
    5. Recreates the deposit procedure and reporting views.
*/

USE CafeDB;
GO

SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.users', 'U') IS NULL
   OR OBJECT_ID('dbo.products', 'U') IS NULL
   OR OBJECT_ID('dbo.orders', 'U') IS NULL
   OR OBJECT_ID('dbo.order_items', 'U') IS NULL
BEGIN
    THROW 51030, 'CafeDB core tables are missing. Run database/rebuild.sql first.', 1;
END;
GO

/* --------------------------------------------------------------------------
   1. Repair the order schema used by checkout/deposit Java code.
   -------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.orders', 'order_type') IS NULL
    ALTER TABLE dbo.orders ADD order_type VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_order_type DEFAULT 'direct' WITH VALUES;

IF COL_LENGTH('dbo.orders', 'payment_method') IS NULL
    ALTER TABLE dbo.orders ADD payment_method VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_payment_method DEFAULT 'cash' WITH VALUES;

IF COL_LENGTH('dbo.orders', 'deposit_amount') IS NULL
    ALTER TABLE dbo.orders ADD deposit_amount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_orders_deposit_amount DEFAULT 0 WITH VALUES;

IF COL_LENGTH('dbo.orders', 'pickup_date') IS NULL
    ALTER TABLE dbo.orders ADD pickup_date DATE NULL;

IF COL_LENGTH('dbo.orders', 'pickup_status') IS NULL
    ALTER TABLE dbo.orders ADD pickup_status VARCHAR(20) NULL;

IF COL_LENGTH('dbo.orders', 'completed_at') IS NULL
    ALTER TABLE dbo.orders ADD completed_at DATETIME2 NULL;

IF COL_LENGTH('dbo.orders', 'cancelled_at') IS NULL
    ALTER TABLE dbo.orders ADD cancelled_at DATETIME2 NULL;

IF COL_LENGTH('dbo.orders', 'cancellation_reason') IS NULL
    ALTER TABLE dbo.orders ADD cancellation_reason NVARCHAR(300) NULL;
GO

UPDATE dbo.orders
SET completed_at = COALESCE(completed_at, order_date)
WHERE status = 'completed'
  AND completed_at IS NULL;
GO

IF EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_orders_status'
      AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders DROP CONSTRAINT CK_orders_status;
GO

ALTER TABLE dbo.orders WITH CHECK ADD CONSTRAINT CK_orders_status CHECK (
    status IN (
        'pending', 'completed', 'deposit_pending', 'picked_up',
        'no_show', 'cancelled', 'refunded'
    )
);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_orders_type'
      AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders WITH CHECK ADD CONSTRAINT CK_orders_type
        CHECK (order_type IN ('direct', 'deposit'));

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_orders_payment_method'
      AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders WITH CHECK ADD CONSTRAINT CK_orders_payment_method
        CHECK (payment_method IN ('cash', 'vnpay'));

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_orders_deposit_amount'
      AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders WITH CHECK ADD CONSTRAINT CK_orders_deposit_amount
        CHECK (deposit_amount >= 0 AND deposit_amount <= total_amount);

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_orders_pickup_status'
      AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders WITH CHECK ADD CONSTRAINT CK_orders_pickup_status
        CHECK (pickup_status IS NULL OR pickup_status IN ('pending', 'picked_up', 'no_show'));
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_orders_user_date'
      AND object_id = OBJECT_ID('dbo.orders')
)
    CREATE INDEX IX_orders_user_date ON dbo.orders(user_id, order_date DESC);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_orders_pending_deposits'
      AND object_id = OBJECT_ID('dbo.orders')
)
    CREATE INDEX IX_orders_pending_deposits
        ON dbo.orders(status, pickup_date)
        INCLUDE (user_id, deposit_amount)
        WHERE order_type = 'deposit';
GO

/* --------------------------------------------------------------------------
   2. Connect promotion_items to promotions (PROMOTIONS M:N PRODUCTS).
   -------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.promotion_items', 'promotion_id') IS NULL
    ALTER TABLE dbo.promotion_items ADD promotion_id INT NULL;
GO

IF EXISTS (SELECT 1 FROM dbo.promotion_items WHERE promotion_id IS NULL)
   AND NOT EXISTS (SELECT 1 FROM dbo.promotions)
BEGIN
    INSERT INTO dbo.promotions
        (title, description, discount_percent, start_date, end_date, image_url, status)
    SELECT
        N'Khuyến mãi sản phẩm đã chuyển đổi',
        N'Tạo tự động khi nâng cấp quan hệ ERD.',
        MAX(discount_percent),
        MIN(start_date),
        MAX(end_date),
        NULL,
        'active'
    FROM dbo.promotion_items;
END;
GO

UPDATE dbo.promotion_items
SET promotion_id = (SELECT TOP (1) id FROM dbo.promotions ORDER BY id)
WHERE promotion_id IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.promotion_items WHERE promotion_id IS NULL)
   AND EXISTS (
       SELECT 1
       FROM sys.columns
       WHERE object_id = OBJECT_ID('dbo.promotion_items')
         AND name = 'promotion_id'
         AND is_nullable = 1
   )
    ALTER TABLE dbo.promotion_items ALTER COLUMN promotion_id INT NOT NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_promotion_items_promotion'
      AND parent_object_id = OBJECT_ID('dbo.promotion_items')
)
    ALTER TABLE dbo.promotion_items WITH CHECK
        ADD CONSTRAINT FK_promotion_items_promotion
        FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(id) ON DELETE CASCADE;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_promotion_items_promotion_product'
      AND object_id = OBJECT_ID('dbo.promotion_items')
)
    CREATE INDEX IX_promotion_items_promotion_product
        ON dbo.promotion_items(promotion_id, product_id);
GO

/* --------------------------------------------------------------------------
   3. Optional ownership/audit relationships for the remaining master tables.
   -------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.promotions', 'created_by_user_id') IS NULL
    ALTER TABLE dbo.promotions ADD created_by_user_id INT NULL;

IF COL_LENGTH('dbo.contacts', 'user_id') IS NULL
    ALTER TABLE dbo.contacts ADD user_id INT NULL;

IF COL_LENGTH('dbo.system_settings', 'updated_by_user_id') IS NULL
    ALTER TABLE dbo.system_settings ADD updated_by_user_id INT NULL;
GO

UPDATE pr
SET created_by_user_id = creator.id
FROM dbo.promotions pr
CROSS APPLY (SELECT TOP (1) id FROM dbo.users ORDER BY CASE WHEN role = 'admin' THEN 0 ELSE 1 END, id) creator
WHERE pr.created_by_user_id IS NULL;

UPDATE c
SET user_id = u.id
FROM dbo.contacts c
INNER JOIN dbo.users u ON u.email = c.email
WHERE c.user_id IS NULL;

UPDATE ss
SET updated_by_user_id = updater.id
FROM dbo.system_settings ss
CROSS APPLY (SELECT TOP (1) id FROM dbo.users ORDER BY CASE WHEN role = 'admin' THEN 0 ELSE 1 END, id) updater
WHERE ss.updated_by_user_id IS NULL;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_promotions_created_by'
      AND parent_object_id = OBJECT_ID('dbo.promotions')
)
    ALTER TABLE dbo.promotions WITH CHECK
        ADD CONSTRAINT FK_promotions_created_by
        FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id);

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_contacts_user'
      AND parent_object_id = OBJECT_ID('dbo.contacts')
)
    ALTER TABLE dbo.contacts WITH CHECK
        ADD CONSTRAINT FK_contacts_user
        FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE SET NULL;

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_system_settings_updated_by'
      AND parent_object_id = OBJECT_ID('dbo.system_settings')
)
    ALTER TABLE dbo.system_settings WITH CHECK
        ADD CONSTRAINT FK_system_settings_updated_by
        FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id);
GO

/* --------------------------------------------------------------------------
   4. Normalized payment ledger and order status history.
   -------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.payments', 'U') IS NULL
BEGIN
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
        CONSTRAINT CK_payments_method
            CHECK (payment_method IN ('cash', 'vnpay')),
        CONSTRAINT CK_payments_amount CHECK (amount >= 0),
        CONSTRAINT CK_payments_status
            CHECK (status IN ('pending', 'paid', 'failed', 'refunded'))
    );
END;
GO

IF OBJECT_ID('dbo.order_status_history', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.order_status_history (
        id             BIGINT IDENTITY(1,1) PRIMARY KEY,
        order_id       INT NOT NULL,
        old_status     VARCHAR(30) NULL,
        new_status     VARCHAR(30) NOT NULL,
        note           NVARCHAR(300) NULL,
        changed_at     DATETIME2 NOT NULL CONSTRAINT DF_order_history_changed_at DEFAULT SYSDATETIME(),
        changed_by_id  INT NULL,
        CONSTRAINT FK_order_history_order
            FOREIGN KEY (order_id) REFERENCES dbo.orders(id) ON DELETE CASCADE,
        CONSTRAINT FK_order_history_user
            FOREIGN KEY (changed_by_id) REFERENCES dbo.users(id)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_payments_order_date'
      AND object_id = OBJECT_ID('dbo.payments')
)
    CREATE INDEX IX_payments_order_date ON dbo.payments(order_id, created_at DESC);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_order_history_order_date'
      AND object_id = OBJECT_ID('dbo.order_status_history')
)
    CREATE INDEX IX_order_history_order_date
        ON dbo.order_status_history(order_id, changed_at DESC);
GO

INSERT INTO dbo.payments
    (order_id, payment_stage, payment_method, amount, status, paid_at)
SELECT
    o.id,
    CASE WHEN o.order_type = 'deposit' THEN 'deposit' ELSE 'full' END,
    o.payment_method,
    CASE WHEN o.order_type = 'deposit' THEN o.deposit_amount ELSE o.total_amount END,
    CASE WHEN o.status = 'pending' THEN 'pending' ELSE 'paid' END,
    CASE WHEN o.status = 'pending' THEN NULL ELSE COALESCE(o.completed_at, o.order_date) END
FROM dbo.orders o
WHERE NOT EXISTS (SELECT 1 FROM dbo.payments p WHERE p.order_id = o.id);

INSERT INTO dbo.order_status_history (order_id, old_status, new_status, note, changed_at)
SELECT o.id, NULL, o.status, N'Dữ liệu lịch sử được khởi tạo khi nâng cấp ERD.', o.order_date
FROM dbo.orders o
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.order_status_history h WHERE h.order_id = o.id
);
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

/* --------------------------------------------------------------------------
   5. Deposit lifecycle and reporting views.
   -------------------------------------------------------------------------- */
IF NOT EXISTS (
    SELECT 1 FROM dbo.system_settings WHERE setting_key = 'deposit_percent'
)
    INSERT INTO dbo.system_settings(setting_key, setting_value, description)
    VALUES ('deposit_percent', '30', N'Phần trăm tiền cọc mặc định');
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
        SELECT order_id, SUM(amount) AS amount, 'paid' AS status
        FROM dbo.payments
        WHERE status = 'paid'
        GROUP BY order_id
    ) pay ON pay.order_id = o.id
    GROUP BY
        o.id, o.user_id, u.username, u.fullname, o.order_date, o.status,
        o.total_amount, o.order_type, o.payment_method, o.deposit_amount,
        o.pickup_date, o.pickup_status;
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

PRINT 'V007 complete: order schema repaired and full ERD relations installed.';
GO
