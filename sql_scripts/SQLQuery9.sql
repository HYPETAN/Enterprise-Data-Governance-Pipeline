USE EnterpriseDiveDB;
GO

-- 1. Pick a random diver (Let's say Diver_ID 5)
SELECT * FROM Diver WHERE Diver_ID = 5;

-- 2. Update their email (This triggers the System Versioning)
UPDATE Diver
SET Email = 'changed_email@test.com'
WHERE Diver_ID = 5;

-- 3. Check the History Table
SELECT * FROM Diver_History WHERE Diver_ID = 5;