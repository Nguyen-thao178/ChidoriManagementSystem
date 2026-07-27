/*
  Exact barcode lookup used by ProductDAO.getByBarcode.
  Run after V002_add_product_barcode.sql.
*/

USE CafeDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_products_find_by_barcode
    @barcode VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @normalized_barcode VARCHAR(64) = NULLIF(LTRIM(RTRIM(@barcode)), '');

    SELECT
        id,
        name,
        price,
        description,
        stock,
        sold_count,
        image_url,
        category,
        barcode
    FROM dbo.products
    WHERE barcode = @normalized_barcode;
END;
GO

/*
  Verification query. Each returned count must be exactly 1.

  SELECT barcode, COUNT(*) AS matching_products
  FROM dbo.products
  WHERE barcode IS NOT NULL
  GROUP BY barcode
  HAVING COUNT(*) <> 1;
*/
