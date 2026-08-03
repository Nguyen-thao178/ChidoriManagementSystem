/* Add the application-wide settings consumed by the Java/JSP runtime. */
USE CafeDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @admin_id INT = (SELECT TOP (1) id FROM dbo.users WHERE role = 'admin' ORDER BY id);

MERGE dbo.system_settings WITH (HOLDLOCK) AS target
USING (VALUES
    ('store_name', N'Chidori Coffee', N'Tên cửa hàng'),
    ('store_tagline', N'Thương hiệu cà phê rang xay nguyên chất', N'Mô tả ngắn của cửa hàng'),
    ('hotline', N'1900 1234', N'Số điện thoại hỗ trợ'),
    ('address', N'123 Đường Cà Phê, Quận 1, TP.HCM', N'Địa chỉ cửa hàng'),
    ('weekday_hours', N'Thứ 2 - Thứ 6: 7:00 - 21:00', N'Giờ mở cửa ngày trong tuần'),
    ('weekend_hours', N'Thứ 7 - CN: 8:00 - 22:00', N'Giờ mở cửa cuối tuần'),
    ('social_links', N'Facebook | Instagram | Tiktok', N'Các kênh mạng xã hội'),
    ('currency', N'VND', N'Đơn vị tiền tệ hiển thị'),
    ('deposit_percent', N'30', N'Phần trăm tiền cọc mặc định'),
    ('loyalty_vnd_per_point', N'1000', N'Số tiền chi tiêu để nhận một điểm'),
    ('barcode_scanner_enabled', N'true', N'Cho phép thêm sản phẩm bằng máy quét mã vạch')
) AS source(setting_key, setting_value, description)
ON target.setting_key = source.setting_key
WHEN MATCHED THEN
    UPDATE SET description = source.description
WHEN NOT MATCHED THEN
    INSERT (updated_by_user_id, setting_key, setting_value, description)
    VALUES (@admin_id, source.setting_key, source.setting_value, source.description);

COMMIT TRANSACTION;
GO

PRINT N'V011 applied: functional system settings are ready.';
GO
