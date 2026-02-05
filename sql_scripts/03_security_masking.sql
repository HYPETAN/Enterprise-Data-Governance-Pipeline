/* 03_security_masking.sql */
USE EnterpriseDiveDB;
GO

/*
   DATA PRIVACY (GDPR/PII COMPLIANCE)
   Masking sensitive columns so analysts can query stats 
   without seeing personal details.
*/

-- Mask Email: "a***@****.com"
ALTER TABLE Diver
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

-- Mask Last Name: "Sxxxx"
ALTER TABLE Diver
ALTER COLUMN Last_Name ADD MASKED WITH (FUNCTION = 'partial(1, "xxxx", 0)');

-- Create a dummy user to test the security
CREATE USER DataAnalyst WITHOUT LOGIN;
GRANT SELECT ON Diver TO DataAnalyst;

-- EXECUTE AS USER = 'DataAnalyst';
-- SELECT * FROM Diver; -- Takes masked data
-- REVERT;