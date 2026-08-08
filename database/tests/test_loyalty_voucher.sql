SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRANSACTION;

DECLARE @username VARCHAR(80) = 'test_loyalty_' + REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '');
INSERT INTO dbo.users (username, password_hash, fullname, email, role)
VALUES (@username, 'test-only', N'Khách test loyalty', @username + '@local.test', 'member');
DECLARE @user_id INT = SCOPE_IDENTITY();

INSERT INTO dbo.member_profiles (user_id, membership_code, phone, address)
VALUES (@user_id, 'T' + CAST(@user_id AS VARCHAR(19)), '0900000000', N'Địa chỉ kiểm thử');
UPDATE dbo.loyalty_points SET points = 100 WHERE user_id = @user_id;

DECLARE @product_id INT = (SELECT TOP (1) id FROM dbo.products ORDER BY id);
INSERT INTO dbo.orders
    (user_id, total_amount, gross_amount, status, order_type, payment_method,
     deposit_amount, pickup_date, pickup_status, loyalty_points_used,
     loyalty_discount_amount)
VALUES
    (@user_id, 20000, 100000, 'deposit_pending', 'deposit', 'vnpay',
     6000, DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 'pending', 80, 80000);
DECLARE @order_id INT = SCOPE_IDENTITY();
INSERT INTO dbo.order_items (order_id, product_id, quantity, price)
VALUES (@order_id, @product_id, 1, 100000);
UPDATE dbo.loyalty_points SET points = points - 80 WHERE user_id = @user_id;

EXEC dbo.usp_expire_overdue_deposits;
IF (SELECT points FROM dbo.loyalty_points WHERE user_id = @user_id) <> 100
    THROW 52001, 'No-show did not refund loyalty points.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.orders WHERE id = @order_id AND status = 'no_show'
               AND loyalty_points_refunded = 1)
    THROW 52002, 'No-show order state is incorrect.', 1;

EXEC dbo.usp_expire_overdue_deposits;
IF (SELECT points FROM dbo.loyalty_points WHERE user_id = @user_id) <> 100
    THROW 52003, 'Loyalty refund was applied more than once.', 1;

ROLLBACK TRANSACTION;
PRINT 'PASS: member loyalty voucher and idempotent no-show refund';
