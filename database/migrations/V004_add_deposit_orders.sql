/*
  Add direct/deposit transaction tracking to an existing CafeDB.
  Run after V002 and V003.
*/

USE CafeDB;
GO

IF COL_LENGTH('dbo.orders', 'order_type') IS NULL
    ALTER TABLE dbo.orders ADD order_type VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_order_type DEFAULT 'direct';
IF COL_LENGTH('dbo.orders', 'payment_method') IS NULL
    ALTER TABLE dbo.orders ADD payment_method VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_payment_method DEFAULT 'cash';
IF COL_LENGTH('dbo.orders', 'deposit_amount') IS NULL
    ALTER TABLE dbo.orders ADD deposit_amount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_orders_deposit_amount DEFAULT 0;
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

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_orders_status' AND parent_object_id = OBJECT_ID('dbo.orders')
)
    ALTER TABLE dbo.orders DROP CONSTRAINT CK_orders_status;
GO

ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_status CHECK (
    status IN ('pending', 'completed', 'deposit_pending', 'picked_up', 'no_show', 'cancelled', 'refunded')
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_orders_type')
    ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_type
        CHECK (order_type IN ('direct', 'deposit'));
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_orders_payment_method')
    ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_payment_method
        CHECK (payment_method IN ('cash', 'vnpay'));
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_orders_deposit_amount')
    ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_deposit_amount
        CHECK (deposit_amount >= 0 AND deposit_amount <= total_amount);
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_orders_pickup_status')
    ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_pickup_status
        CHECK (pickup_status IS NULL OR pickup_status IN ('pending', 'picked_up', 'no_show'));
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_orders_pending_deposits' AND object_id = OBJECT_ID('dbo.orders')
)
BEGIN
    CREATE INDEX IX_orders_pending_deposits
        ON dbo.orders(status, pickup_date)
        INCLUDE (user_id, deposit_amount)
        WHERE order_type = 'deposit';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.system_settings WHERE setting_key = 'deposit_percent'
)
BEGIN
    INSERT INTO dbo.system_settings(setting_key, setting_value, description)
    VALUES ('deposit_percent', '30', N'Phần trăm tiền cọc mặc định');
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
