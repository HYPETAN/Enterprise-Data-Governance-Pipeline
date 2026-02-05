USE EnterpriseDiveDB;
GO

CREATE OR ALTER PROCEDURE sp_Load_Divers_From_Staging
AS
BEGIN
    SET NOCOUNT ON;

    -- A. De-duplicate the Incoming Data using a CTE
    -- We group by Email and pick the 'latest' one if duplicates exist in the batch.
    WITH UniqueStaging AS (
        SELECT 
            Raw_First, 
            Raw_Last, 
            Raw_Email, 
            Raw_DOB,
            ROW_NUMBER() OVER (PARTITION BY Raw_Email ORDER BY Ingested_At DESC) as RowNum
        FROM Staging.Raw_Divers
        WHERE Raw_Email LIKE '%@%.%'  -- Only Valid Emails
          AND ISDATE(Raw_DOB) = 1     -- Only Valid Dates
    )
    -- B. Insert into Production
    INSERT INTO dbo.Diver (First_Name, Last_Name, Email, Date_Of_Birth, Certification_Level)
    SELECT 
        Raw_First, 
        Raw_Last, 
        Raw_Email, 
        CAST(Raw_DOB AS DATE), 
        'Beginner'
    FROM UniqueStaging s
    WHERE RowNum = 1 -- <--- This keeps only the first instance of any duplicate email
      AND NOT EXISTS (SELECT 1 FROM dbo.Diver d WHERE d.Email = s.Raw_Email); -- Check Production history

    -- C. Handle Invalid Data (Quarantine)
    INSERT INTO dbo.Data_Quarantine (Record_ID, Raw_Data, Error_Message)
    SELECT 
        Staging_ID, 
        Raw_First + '|' + Raw_Email, 
        'Invalid Email or Date Format'
    FROM Staging.Raw_Divers
    WHERE Raw_Email NOT LIKE '%@%.%' 
       OR ISDATE(Raw_DOB) = 0;

    -- D. Cleanup
    TRUNCATE TABLE Staging.Raw_Divers;
END;
GO