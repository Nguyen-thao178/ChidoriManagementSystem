/*
  Integration test for dbo.usp_products_find_by_barcode.
  The transaction is always rolled back, so product data is not retained.
*/

USE CafeDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @coffee_id INT;
    DECLARE @tea_id INT;

    INSERT INTO dbo.products
        (name, price, description, stock, sold_count, image_url, category, barcode)
    VALUES
        (N'Barcode test coffee', 35000, NULL, 5, 0, NULL, N'Coffee', '9900000000017');
    SET @coffee_id = SCOPE_IDENTITY();

    INSERT INTO dbo.products
        (name, price, description, stock, sold_count, image_url, category, barcode)
    VALUES
        (N'Barcode test tea', 45000, NULL, 5, 0, NULL, N'Tea', '9900000000024');
    SET @tea_id = SCOPE_IDENTITY();

    DECLARE @result TABLE (
        id INT,
        name NVARCHAR(150),
        price DECIMAL(18,2),
        description NVARCHAR(1000),
        stock INT,
        sold_count INT,
        image_url NVARCHAR(1000),
        category NVARCHAR(80),
        barcode VARCHAR(64)
    );

    INSERT INTO @result
    EXEC dbo.usp_products_find_by_barcode @barcode = '9900000000024';

    IF (SELECT COUNT(*) FROM @result) <> 1
        THROW 51010, 'Barcode lookup must return exactly one product.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM @result
        WHERE id = @tea_id
          AND name = N'Barcode test tea'
          AND barcode = '9900000000024'
    )
        THROW 51011, 'Barcode lookup returned the wrong product.', 1;

    IF EXISTS (SELECT 1 FROM @result WHERE id = @coffee_id)
        THROW 51012, 'Barcode lookup returned a product belonging to another barcode.', 1;

    PRINT 'PASS: EAN-13 test barcode returned exactly the matching tea product.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
