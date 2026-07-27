/*
  Switch product scanning to EAN-13 and assign the approved product catalog.
  Run after V005.
*/

USE CafeDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_products_barcode'
      AND parent_object_id = OBJECT_ID('dbo.products')
)
    ALTER TABLE dbo.products DROP CONSTRAINT CK_products_barcode;

-- Clear the four target rows first so unique barcode values can be reassigned safely.
UPDATE dbo.products
SET barcode = NULL
WHERE name IN (N'Cà phê sữa', N'Cà phê đen', N'Trà đào', N'Bánh sừng bò')
   OR barcode IN ('8938501434012', '8938501434029', '8938501434036', '8938501434043');

UPDATE dbo.products SET barcode = '8938501434012' WHERE name = N'Cà phê sữa';
UPDATE dbo.products SET barcode = '8938501434029' WHERE name = N'Cà phê đen';
UPDATE dbo.products SET barcode = '8938501434036' WHERE name = N'Trà đào';
UPDATE dbo.products SET barcode = '8938501434043' WHERE name = N'Bánh sừng bò';

IF (
    SELECT COUNT(*)
    FROM dbo.products
    WHERE (name = N'Cà phê sữa' AND barcode = '8938501434012')
       OR (name = N'Cà phê đen' AND barcode = '8938501434029')
       OR (name = N'Trà đào' AND barcode = '8938501434036')
       OR (name = N'Bánh sừng bò' AND barcode = '8938501434043')
) <> 4
BEGIN
    ROLLBACK TRANSACTION;
    THROW 51030, 'Could not assign all four EAN-13 barcodes. Check product names.', 1;
END;

ALTER TABLE dbo.products ADD CONSTRAINT CK_products_barcode CHECK (
    barcode IS NULL
    OR (
        LEN(barcode) = 13
        AND barcode NOT LIKE '%[^0-9]%'
    )
);

COMMIT TRANSACTION;
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
           SELECT 1 FROM dbo.products
           WHERE barcode = @normalized_barcode AND id <> @product_id
       )
        THROW 51004, 'Barcode is already assigned to another product.', 1;

    UPDATE dbo.products
    SET barcode = @normalized_barcode
    WHERE id = @product_id;
END;
GO

SELECT id, name, barcode, stock
FROM dbo.products
WHERE barcode IN ('8938501434012', '8938501434029', '8938501434036', '8938501434043')
ORDER BY barcode;
GO
