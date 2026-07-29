/*
  Idempotent development accounts for the documented role hierarchy.
  Passwords are stored only as PBKDF2-HMAC-SHA256 hashes.
*/
USE CafeDB;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF EXISTS (SELECT 1 FROM dbo.users WHERE username = 'admin')
BEGIN
    UPDATE dbo.users
       SET password_hash = 'pbkdf2$210000$JeFAEjpfXxgGTdzBc6t97w$saF7Jxjo5ziAMct8Eye5_1AIB-_gdkLsx1Lr6RjpHs4',
           fullname = N'Chidori Administrator',
           email = 'admin@chidori.local',
           role = 'admin'
     WHERE username = 'admin';
END
ELSE
BEGIN
    INSERT INTO dbo.users(username, password_hash, fullname, email, role)
    VALUES (
        'admin',
        'pbkdf2$210000$JeFAEjpfXxgGTdzBc6t97w$saF7Jxjo5ziAMct8Eye5_1AIB-_gdkLsx1Lr6RjpHs4',
        N'Chidori Administrator',
        'admin@chidori.local',
        'admin'
    );
END;

IF EXISTS (SELECT 1 FROM dbo.users WHERE username = 'manager1')
BEGIN
    UPDATE dbo.users
       SET password_hash = 'pbkdf2$210000$ijizkzJXcvfVJsUyh42m-Q$f077hGlLsI6oP6CL3-tkYaShCLTZlwDznUVC0GY590s',
           fullname = N'Quản lý Chidori',
           email = 'manager1@chidori.local',
           role = 'manager'
     WHERE username = 'manager1';
END
ELSE
BEGIN
    INSERT INTO dbo.users(username, password_hash, fullname, email, role)
    VALUES (
        'manager1',
        'pbkdf2$210000$ijizkzJXcvfVJsUyh42m-Q$f077hGlLsI6oP6CL3-tkYaShCLTZlwDznUVC0GY590s',
        N'Quản lý Chidori',
        'manager1@chidori.local',
        'manager'
    );
END;

IF EXISTS (SELECT 1 FROM dbo.users WHERE username = 'staff1')
BEGIN
    UPDATE dbo.users
       SET password_hash = 'pbkdf2$210000$fI4PX7eBtBv2sgKiLYO63Q$XzIlXu1ptMT_JXXh5l0IzDGo1AKH9LZrBAu4N3oqCCQ',
           fullname = N'Nhân viên Chidori',
           email = 'staff1@chidori.local',
           role = 'staff'
     WHERE username = 'staff1';
END
ELSE
BEGIN
    INSERT INTO dbo.users(username, password_hash, fullname, email, role)
    VALUES (
        'staff1',
        'pbkdf2$210000$fI4PX7eBtBv2sgKiLYO63Q$XzIlXu1ptMT_JXXh5l0IzDGo1AKH9LZrBAu4N3oqCCQ',
        N'Nhân viên Chidori',
        'staff1@chidori.local',
        'staff'
    );
END;

COMMIT TRANSACTION;
GO

PRINT N'V010 applied: admin, manager and staff accounts are ready.';
GO
