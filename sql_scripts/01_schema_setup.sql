/* 01_schema_setup.sql */
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'EnterpriseDiveDB')
BEGIN
    ALTER DATABASE EnterpriseDiveDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EnterpriseDiveDB;
END
GO

CREATE DATABASE EnterpriseDiveDB;
GO
USE EnterpriseDiveDB;
GO

-- 1. LOOKUP TABLES (Standardized Data)
CREATE TABLE Dive_Site (
    Site_ID INT IDENTITY(1,1) PRIMARY KEY,
    Site_Name VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    Difficulty_Level VARCHAR(50) CHECK (Difficulty_Level IN ('Easy', 'Medium', 'Hard', 'Expert'))
);

CREATE TABLE Equipment (
    Equipment_ID INT IDENTITY(1,1) PRIMARY KEY,
    Equipment_Name VARCHAR(100) NOT NULL,
    Total_Stock INT CHECK (Total_Stock >= 0),
    Condition VARCHAR(50) NOT NULL
);

-- 2. MAIN ENTITY (With Data Governance Constraints)
CREATE TABLE Diver (
    Diver_ID INT IDENTITY(1,1) PRIMARY KEY,
    First_Name VARCHAR(100) NOT NULL,
    Last_Name VARCHAR(100) NOT NULL,
    -- Constraint: Age Validation (Must be >10 years old)
    Date_Of_Birth DATE NOT NULL CHECK (Date_Of_Birth <= DATEADD(YEAR, -10, GETDATE())),
    -- Constraint: Email Format Validation
    Email VARCHAR(100) NOT NULL UNIQUE CHECK (Email LIKE '%@%.%'), 
    Certification_Level VARCHAR(50) NOT NULL,
    Membership_Date DATE DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Active'
);

-- 3. TRANSACTION TABLES
CREATE TABLE Dive_Tour (
    Tour_ID INT IDENTITY(1,1) PRIMARY KEY,
    Tour_Name VARCHAR(100) NOT NULL,
    Site_ID INT FOREIGN KEY REFERENCES Dive_Site(Site_ID),
    Tour_Date DATE NOT NULL,
    -- Constraint: Price cannot be negative
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    Max_Participants INT NOT NULL,
    Guide_ID INT FOREIGN KEY REFERENCES Diver(Diver_ID)
);

CREATE TABLE Dive_Log (
    Log_ID INT IDENTITY(1,1) PRIMARY KEY,
    Diver_ID INT FOREIGN KEY REFERENCES Diver(Diver_ID),
    Site_ID INT FOREIGN KEY REFERENCES Dive_Site(Site_ID),
    Date_Of_Dive DATE NOT NULL,
    -- Constraint: Depth Safety Limit (e.g., 150m max)
    Max_Depth INT CHECK (Max_Depth > 0 AND Max_Depth < 150),
    Notes TEXT
);

-- 4. BRIDGE TABLE (The Professional Fix)
-- Allows one dive to use multiple pieces of equipment (Mask + Fins + Tank)
CREATE TABLE Dive_Log_Equipment (
    Log_ID INT FOREIGN KEY REFERENCES Dive_Log(Log_ID),
    Equipment_ID INT FOREIGN KEY REFERENCES Equipment(Equipment_ID),
    PRIMARY KEY (Log_ID, Equipment_ID)
);


-- 5. CERTIFICATION (Tracks Diver Qualifications)
CREATE TABLE Certification (
    Certification_ID INT IDENTITY(1,1) PRIMARY KEY,
    Diver_ID INT FOREIGN KEY REFERENCES Diver(Diver_ID),
    Certification_Type VARCHAR(100) NOT NULL, -- e.g., 'PADI Open Water'
    Certification_Level VARCHAR(50) CHECK (Certification_Level IN ('Beginner', 'Advanced', 'Professional', 'Specialty')),
    Certification_Date DATE NOT NULL,
    Expiry_Date DATE,
    Issued_By VARCHAR(100) DEFAULT 'PADI'
);

-- 6. DIVE PARTICIPATION (Links Divers to Tours)
CREATE TABLE Dive_Participation (
    Participation_ID INT IDENTITY(1,1) PRIMARY KEY,
    Diver_ID INT FOREIGN KEY REFERENCES Diver(Diver_ID),
    Tour_ID INT FOREIGN KEY REFERENCES Dive_Tour(Tour_ID),
    SignUp_Date DATE DEFAULT GETDATE(),
    Payment_Status VARCHAR(50) CHECK (Payment_Status IN ('Paid', 'Pending', 'Refunded', 'Cancelled'))
);
GO