/*
  Integration test for automatic deposit expiration.
  All test data is rolled back.
*/

USE CafeDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @user_id INT;
    DECLARE @product_id INT;
    DECLARE @order_id INT;

    INSERT INTO dbo.users(username, password_hash, fullname, email, role)
    VALUES (
        'deposit_test_user',
        REPLICATE('0', 64),
        N'Deposit Test User',
        'deposit-test@chidori.local',
        'member'
    );
    SET @user_id = SCOPE_IDENTITY();

    INSERT INTO dbo.products(name, price, stock, sold_count, category, barcode)
    VALUES (N'Deposit test product', 100000, 4, 0, N'Test', NULL);
    SET @product_id = SCOPE_IDENTITY();

    INSERT INTO dbo.orders(
        user_id, total_amount, status, order_type, payment_method,
        deposit_amount, pickup_date, pickup_status
    )
    VALUES (
        @user_id, 100000, 'deposit_pending', 'deposit', 'cash',
        30000, DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 'pending'
    );
    SET @order_id = SCOPE_IDENTITY();

    INSERT INTO dbo.order_items(order_id, product_id, quantity, price)
    VALUES (@order_id, @product_id, 1, 100000);

    EXEC dbo.usp_expire_overdue_deposits;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.orders
        WHERE id = @order_id
          AND status = 'no_show'
          AND pickup_status = 'no_show'
          AND cancellation_reason = N'Không nhận hàng'
    )
        THROW 51020, 'Expired deposit did not receive the no-show status.', 1;

    IF (SELECT stock FROM dbo.products WHERE id = @product_id) <> 5
        THROW 51021, 'Reserved inventory was not returned after expiration.', 1;

    PRINT 'PASS: overdue deposit became no_show and reserved stock was returned.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
