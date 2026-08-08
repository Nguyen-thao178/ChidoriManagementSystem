SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

IF OBJECT_ID('dbo.member_profiles', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.member_profiles (
        id              INT IDENTITY(1,1) PRIMARY KEY,
        user_id         INT NOT NULL,
        membership_code VARCHAR(20) NOT NULL,
        phone           VARCHAR(20) NOT NULL,
        birth_date      DATE NULL,
        address         NVARCHAR(500) NOT NULL,
        joined_at       DATETIME2 NOT NULL CONSTRAINT DF_member_profiles_joined DEFAULT SYSDATETIME(),
        status          VARCHAR(20) NOT NULL CONSTRAINT DF_member_profiles_status DEFAULT 'active',
        CONSTRAINT UX_member_profiles_user UNIQUE (user_id),
        CONSTRAINT UX_member_profiles_code UNIQUE (membership_code),
        CONSTRAINT FK_member_profiles_user FOREIGN KEY (user_id)
            REFERENCES dbo.users(id) ON DELETE CASCADE,
        CONSTRAINT CK_member_profiles_status CHECK (status IN ('active', 'inactive'))
    );
END;
GO

IF COL_LENGTH('dbo.orders', 'gross_amount') IS NULL
    ALTER TABLE dbo.orders ADD gross_amount DECIMAL(18,2) NULL;
IF COL_LENGTH('dbo.orders', 'loyalty_points_used') IS NULL
    ALTER TABLE dbo.orders ADD loyalty_points_used INT NOT NULL
        CONSTRAINT DF_orders_loyalty_points_used DEFAULT 0;
IF COL_LENGTH('dbo.orders', 'loyalty_discount_amount') IS NULL
    ALTER TABLE dbo.orders ADD loyalty_discount_amount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_orders_loyalty_discount DEFAULT 0;
IF COL_LENGTH('dbo.orders', 'loyalty_points_refunded') IS NULL
    ALTER TABLE dbo.orders ADD loyalty_points_refunded BIT NOT NULL
        CONSTRAINT DF_orders_loyalty_refunded DEFAULT 0;
GO

UPDATE dbo.orders SET gross_amount = total_amount WHERE gross_amount IS NULL;
ALTER TABLE dbo.orders ALTER COLUMN gross_amount DECIMAL(18,2) NOT NULL;
GO

IF OBJECT_ID('dbo.CK_orders_loyalty_voucher', 'C') IS NULL
    ALTER TABLE dbo.orders ADD CONSTRAINT CK_orders_loyalty_voucher CHECK (
        gross_amount >= total_amount
        AND loyalty_points_used >= 0
        AND loyalty_discount_amount >= 0
        AND loyalty_discount_amount = gross_amount - total_amount
        AND loyalty_discount_amount <= gross_amount * 0.8
    );
GO

CREATE OR ALTER PROCEDURE dbo.usp_expire_overdue_deposits
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;

    DECLARE @expired_orders TABLE (
        order_id INT PRIMARY KEY,
        user_id INT NOT NULL,
        points_used INT NOT NULL
    );

    UPDATE dbo.orders WITH (UPDLOCK, READPAST, ROWLOCK)
    SET status = 'no_show', pickup_status = 'no_show',
        cancelled_at = SYSDATETIME(), cancellation_reason = N'Không nhận hàng',
        loyalty_points_refunded = CASE WHEN loyalty_points_used > 0 THEN 1 ELSE loyalty_points_refunded END
    OUTPUT inserted.id, inserted.user_id,
           CASE WHEN deleted.loyalty_points_refunded = 0 THEN inserted.loyalty_points_used ELSE 0 END
    INTO @expired_orders(order_id, user_id, points_used)
    WHERE order_type = 'deposit' AND status = 'deposit_pending'
      AND pickup_date < CAST(GETDATE() AS DATE);

    UPDATE p SET stock = stock + expired.quantity
    FROM dbo.products p
    INNER JOIN (
        SELECT oi.product_id, SUM(oi.quantity) quantity
        FROM dbo.order_items oi
        INNER JOIN @expired_orders eo ON eo.order_id = oi.order_id
        GROUP BY oi.product_id
    ) expired ON expired.product_id = p.id;

    UPDATE lp SET points = lp.points + refunds.points_used, updated_at = SYSDATETIME()
    FROM dbo.loyalty_points lp
    INNER JOIN (
        SELECT user_id, SUM(points_used) points_used
        FROM @expired_orders GROUP BY user_id
    ) refunds ON refunds.user_id = lp.user_id
    WHERE refunds.points_used > 0;

    DECLARE @expired_count INT = (SELECT COUNT(*) FROM @expired_orders);
    COMMIT TRANSACTION;
    SELECT @expired_count AS expired_count;
END;
GO

CREATE OR ALTER VIEW dbo.vw_member_loyalty
AS
    SELECT u.id user_id, u.username, u.fullname, u.email,
           mp.membership_code, mp.phone, mp.birth_date, mp.address,
           mp.joined_at, mp.status, COALESCE(lp.points, 0) points,
           COALESCE(lp.total_spent, 0) total_spent
    FROM dbo.users u
    INNER JOIN dbo.member_profiles mp ON mp.user_id = u.id
    LEFT JOIN dbo.loyalty_points lp ON lp.user_id = u.id
    WHERE LOWER(u.role) = 'member';
GO
