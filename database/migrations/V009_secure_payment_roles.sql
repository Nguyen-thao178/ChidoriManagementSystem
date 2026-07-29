/*
  Secure VNPay lifecycle, role alignment and password-hash capacity.
  Safe for existing CafeDB data.
*/
USE CafeDB;
GO

SET XACT_ABORT ON;
SET QUOTED_IDENTIFIER ON;
GO

BEGIN TRANSACTION;

ALTER TABLE dbo.users ALTER COLUMN password_hash VARCHAR(255) NOT NULL;

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE parent_object_id = OBJECT_ID('dbo.users')
      AND name = 'CK_users_role'
)
    ALTER TABLE dbo.users DROP CONSTRAINT CK_users_role;

ALTER TABLE dbo.users WITH CHECK ADD CONSTRAINT CK_users_role
    CHECK (role IN ('admin', 'manager', 'staff', 'customer', 'member'));

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.payments')
      AND name = 'UX_payments_transaction_reference'
)
BEGIN
    CREATE UNIQUE INDEX UX_payments_transaction_reference
        ON dbo.payments(transaction_reference)
        WHERE transaction_reference IS NOT NULL;
END;

COMMIT TRANSACTION;
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
END;
GO

PRINT N'V009 applied: secure payment lifecycle, aligned roles and PBKDF2 capacity.';
GO
