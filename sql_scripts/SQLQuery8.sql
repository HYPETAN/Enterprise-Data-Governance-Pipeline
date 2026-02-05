USE EnterpriseDiveDB;
GO

-- 1. Ensure the Schema Exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Staging')
BEGIN
    EXEC('CREATE SCHEMA Staging')
    PRINT 'Schema [Staging] created.'
END
GO

-- 2. Force Re-create the Staging Table
IF OBJECT_ID('Staging.Raw_Divers', 'U') IS NOT NULL 
    DROP TABLE Staging.Raw_Divers;
GO

CREATE TABLE Staging.Raw_Divers (
    Staging_ID INT IDENTITY(1,1) PRIMARY KEY,
    Raw_First VARCHAR(255),
    Raw_Last VARCHAR(255),
    Raw_Email VARCHAR(255),
    Raw_DOB VARCHAR(50),
    Ingested_At DATETIME DEFAULT GETDATE()
);
PRINT 'Table [Staging].[Raw_Divers] created successfully.'
GO

-- 3. Ensure the Quarantine Table Exists
IF OBJECT_ID('dbo.Data_Quarantine', 'U') IS NOT NULL 
    DROP TABLE dbo.Data_Quarantine;
GO

CREATE TABLE dbo.Data_Quarantine (
    Record_ID INT,
    Raw_Data VARCHAR(MAX),
    Error_Message VARCHAR(255),
    Rejected_Date DATETIME DEFAULT GETDATE()
);
PRINT 'Table [dbo].[Data_Quarantine] created successfully.'
GO