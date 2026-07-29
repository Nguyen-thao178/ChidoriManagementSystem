USE CafeDB;
GO

IF OBJECT_ID(N'dbo.chat_history', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.chat_history (
        id         BIGINT IDENTITY(1,1) PRIMARY KEY,
        user_id    INT NULL,
        question   NVARCHAR(500) NOT NULL,
        answer     NVARCHAR(2000) NOT NULL,
        provider   VARCHAR(20) NOT NULL
            CONSTRAINT DF_chat_history_provider DEFAULT 'local',
        created_at DATETIME2 NOT NULL
            CONSTRAINT DF_chat_history_created_at DEFAULT SYSDATETIME(),
        CONSTRAINT FK_chat_history_user
            FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE SET NULL,
        CONSTRAINT CK_chat_history_provider
            CHECK (provider IN ('local', 'gemini'))
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_chat_history_created_at'
      AND object_id = OBJECT_ID(N'dbo.chat_history')
)
BEGIN
    CREATE INDEX IX_chat_history_created_at
        ON dbo.chat_history(created_at DESC)
        INCLUDE (user_id, provider);
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_chat_history_report_by_date
    @report_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ch.id,
        ch.user_id,
        u.username,
        u.fullname,
        ch.question,
        ch.answer,
        ch.provider,
        ch.created_at
    FROM dbo.chat_history ch
    LEFT JOIN dbo.users u ON u.id = ch.user_id
    WHERE ch.created_at >= @report_date
      AND ch.created_at < DATEADD(DAY, 1, @report_date)
    ORDER BY ch.created_at DESC, ch.id DESC;
END;
GO

CREATE OR ALTER VIEW dbo.vw_chat_history_report
AS
    SELECT
        ch.id,
        ch.user_id,
        u.username,
        u.fullname,
        ch.question,
        ch.answer,
        ch.provider,
        ch.created_at
    FROM dbo.chat_history ch
    LEFT JOIN dbo.users u ON u.id = ch.user_id;
GO
