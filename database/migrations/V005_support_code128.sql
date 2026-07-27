/*
  Expand barcode validation for Code 128 payloads and keep exact unique lookup.
*/

USE CafeDB;
GO

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_products_barcode'
      AND parent_object_id = OBJECT_ID('dbo.products')
)
    ALTER TABLE dbo.products DROP CONSTRAINT CK_products_barcode;
GO

ALTER TABLE dbo.products ADD CONSTRAINT CK_products_barcode CHECK (
    barcode IS NULL OR LEN(barcode) BETWEEN 1 AND 64
);
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
       AND LEN(@normalized_barcode) NOT BETWEEN 1 AND 64
        THROW 51003, 'Code 128 payload must contain 1 to 64 characters.', 1;

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

/*
  Replace 1 with the correct product id for the scanned physical item:

  EXEC dbo.usp_products_set_barcode
      @product_id = 1,
      @barcode = '8936221250479';
*/
