/*
  Non-destructive migration for an existing CafeDB database.
  Run this script once in SQL Server Management Studio or with sqlcmd.
*/

USE CafeDB;
GO

IF COL_LENGTH('dbo.products', 'barcode') IS NULL
BEGIN
    ALTER TABLE dbo.products
        ADD barcode VARCHAR(64) NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_products_barcode'
      AND parent_object_id = OBJECT_ID('dbo.products')
)
BEGIN
    ALTER TABLE dbo.products
        ADD CONSTRAINT CK_products_barcode CHECK (
            barcode IS NULL OR (
                LEN(barcode) = 13
                AND barcode NOT LIKE '%[^0-9]%'
            )
        );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_products_barcode'
      AND object_id = OBJECT_ID('dbo.products')
)
BEGIN
    CREATE UNIQUE INDEX UX_products_barcode
        ON dbo.products(barcode)
        WHERE barcode IS NOT NULL;
END;
GO

/*
  Assign real barcodes after the migration, for example:

  UPDATE dbo.products SET barcode = '8938501434012' WHERE id = 1;

  Keep barcodes in quotes so leading zeroes are preserved.
*/
