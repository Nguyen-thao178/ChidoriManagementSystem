# Chidori database setup

This application uses Microsoft SQL Server and the `CafeDB` database.

## Keep existing data

Run these migrations in order:

1. `migrations/V002_add_product_barcode.sql`
2. `migrations/V003_create_barcode_lookup.sql`
3. `migrations/V004_add_deposit_orders.sql`
4. `migrations/V005_support_code128.sql`
5. `migrations/V006_configure_ean13_products.sql`
6. `migrations/V007_complete_order_schema_and_erd.sql`

V006 is the current barcode format. It switches validation to EAN-13 and maps:

- Cà phê sữa: `8938501434012`
- Cà phê đen: `8938501434029`
- Trà đào: `8938501434036`
- Bánh sừng bò: `8938501434043`

V002 adds a nullable `barcode` column and a filtered unique index, so existing
products remain valid. V003 creates the exact lookup procedure used by the
Java DAO.

V004 adds direct/deposit transaction types, cash/VNPay methods, deposit amount,
pickup date, pickup status, the deposit calendar view, and the atomic procedure
that expires overdue deposits and returns reserved stock.

V007 is the current schema repair and relationship migration. It is safe to run
on an existing database and preserves existing rows. It adds any checkout columns
that are still missing, connects `promotions` to `products` through
`promotion_items`, and creates the normalized `payments` and
`order_status_history` tables. See [ERD.md](ERD.md) for the complete relationship
diagram.

## Deposit workflow

- Direct orders are paid in full with cash or VNPay and receive the
  `Thanh toán trực tiếp` history tag.
- Deposit orders charge 30% using cash or VNPay and reserve inventory.
- A pending deposit appears in the `Đơn Hàng Cọc` calendar.
- Confirming pickup changes the tag to `Đã cọc và đã nhận hàng`.
- After the pickup date passes, the hourly application task calls
  `usp_expire_overdue_deposits`. The order is retained for audit with the
  `Đã cọc nhưng không nhận hàng` tag and its reserved stock is returned.

To test the SQL mapping without retaining test products, run:

```powershell
sqlcmd -S localhost -d CafeDB -E -b -i database\tests\test_barcode_lookup.sql
```

The script creates two temporary products inside a transaction, scans the tea
barcode, verifies that only the tea product is returned, and rolls everything
back.
Afterward, assign each product's real barcode in the product administration
screen or with SQL:

```sql
UPDATE dbo.products
SET barcode = '8938501434012'
WHERE id = 1;
```

Barcode values are strings. Always quote them so leading zeroes are preserved.

## Start from a clean database

Run `rebuild.sql` in SQL Server Management Studio or:

```powershell
sqlcmd -S localhost -E -i database\rebuild.sql
```

The rebuild script **drops the complete `CafeDB` database and all data**, then
creates it again from zero. It creates 11 related application tables, stored
procedures, triggers, reporting views, a development administrator, and four
sample products with their fixed EAN-13 barcodes.

Development login after a rebuild:

- Username: `admin`
- Password: `admin123`

Change this password immediately.

## Application connection

The current Java project connects to:

- Server: `localhost:1433`
- Database: `CafeDB`
- SQL user: `sa`

Update `DBConnection.java` and `JdbcUtil.java` for your SQL Server instance.
Do not commit production passwords to Git.

## Scanner behavior

The cart scanner accepts identifiers from 4 to 64 characters containing ASCII
letters, numbers, dots, underscores, and hyphens. This supports common EAN/UPC
values and the usual Code 128 inventory identifiers. Configure the hardware
scanner to send an Enter suffix after each scan.
