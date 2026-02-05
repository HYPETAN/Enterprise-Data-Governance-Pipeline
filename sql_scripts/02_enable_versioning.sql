/* 02_enable_versioning.sql */
USE EnterpriseDiveDB;
GO

/*
   MODERN GOVERNANCE: TEMPORAL TABLES
   Instead of Triggers, we use SQL Server's built-in versioning.
   This creates an immutable history of every change (Insert/Update/Delete).
*/

-- 1. Enable Versioning on DIVER (Track profile changes)
ALTER TABLE Diver
ADD
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_SysStart_Diver DEFAULT SYSUTCDATETIME(),
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_SysEnd_Diver DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
GO

ALTER TABLE Diver
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Diver_History));
GO

-- 2. Enable Versioning on DIVE_TOUR (Track price changes for Audit)
ALTER TABLE Dive_Tour
ADD
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_SysStart_Tour DEFAULT SYSUTCDATETIME(),
    SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_SysEnd_Tour DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);
GO

ALTER TABLE Dive_Tour
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Dive_Tour_History));
GO