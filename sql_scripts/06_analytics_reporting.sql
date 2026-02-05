/* 06_analytics_reporting.sql */
USE EnterpriseDiveDB;
GO

/* =============================================
   SECTION 1: ANALYTICAL VIEWS
   Abstractions for complex joins to simplify Reporting
   ============================================= */

-- View 1: Detailed Dive Log Report
-- (Updated to match the new schema: Removed 'Dive_Time' and 'Equipment_ID')
CREATE OR ALTER VIEW vw_DiveLogs_Detailed AS
SELECT 
    dl.Log_ID,
    dl.Date_Of_Dive,
    dl.Max_Depth,
    dl.Notes,
    d.First_Name,
    d.Last_Name,
    d.Certification_Level,
    s.Site_Name,
    s.Location,
    s.Difficulty_Level
FROM Dive_Log dl
JOIN Diver d ON dl.Diver_ID = d.Diver_ID
JOIN Dive_Site s ON dl.Site_ID = s.Site_ID;
GO

-- View 2: Active Certifications Report
-- (Filters for certifications that have not expired)
CREATE OR ALTER VIEW vw_Active_Certifications AS
SELECT 
    d.Diver_ID,
    d.First_Name,
    d.Last_Name,
    c.Certification_Type,
    c.Certification_Level,
    c.Expiry_Date
FROM Diver d
JOIN Certification c ON d.Diver_ID = c.Diver_ID
WHERE c.Expiry_Date > GETDATE();
GO

-- View 3: Tour Financial Performance
-- (Aggregates revenue per tour)
CREATE OR ALTER VIEW vw_Tour_Financials AS
SELECT 
    dt.Tour_ID,
    dt.Tour_Name,
    dt.Tour_Date,
    dt.Price,
    COUNT(dp.Participation_ID) AS Total_Participants,
    (COUNT(dp.Participation_ID) * dt.Price) AS Total_Revenue
FROM Dive_Tour dt
LEFT JOIN Dive_Participation dp ON dt.Tour_ID = dp.Tour_ID
WHERE dt.Tour_Date >= GETDATE() -- Only future/current tours
GROUP BY dt.Tour_ID, dt.Tour_Name, dt.Tour_Date, dt.Price;
GO


/* =============================================
   SECTION 2: STORED PROCEDURES & FUNCTIONS
   Encapsulated Business Logic
   ============================================= */

-- Procedure: Get Diver's Tour History
-- Includes Error Handling (Try/Catch)
CREATE OR ALTER PROCEDURE sp_GetDiveToursByDiverID
    @DiverID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            dt.Tour_ID,
            dt.Tour_Name,
            dt.Tour_Date,
            dt.Price,
            dt.Max_Participants,
            dp.Payment_Status
        FROM Dive_Tour dt
        JOIN Dive_Participation dp ON dt.Tour_ID = dp.Tour_ID
        WHERE dp.Diver_ID = @DiverID;
    END TRY
    BEGIN CATCH
        PRINT 'Error retrieving diver history: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Function: Calculate Customer Lifetime Value (Tour Spend)
CREATE OR ALTER FUNCTION fn_CalculateTotalTourSpend
(
    @DiverID INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(10, 2);

    SELECT @TotalCost = SUM(dt.Price)
    FROM Dive_Tour dt
    JOIN Dive_Participation dp ON dt.Tour_ID = dp.Tour_ID
    WHERE dp.Diver_ID = @DiverID 
      AND dp.Payment_Status = 'Paid'; -- Only count actual payments

    RETURN ISNULL(@TotalCost, 0); 
END;
GO