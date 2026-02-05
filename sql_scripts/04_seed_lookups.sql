/* 04_seed_lookups.sql */
USE EnterpriseDiveDB;
GO

-- Populate Dive Site (Static Lookup Data)
INSERT INTO Dive_Site (Site_Name, Location, Difficulty_Level)
VALUES 
('Coral Reef', 'Andaman Islands', 'Easy'),
('Wreck Dive', 'Goa', 'Medium'),
('Cave Dive', 'Maharashtra', 'Hard'),
('Shark Point', 'Lakshadweep', 'Medium'),
('Kelp Forest', 'Tamil Nadu', 'Easy');

-- Populate Equipment (Static Inventory)
INSERT INTO Equipment (Equipment_Name, Total_Stock, Condition)
VALUES 
('Snorkel', 15, 'New'),
('Fins', 20, 'Used'),
('Diving Mask', 25, 'New'),
('Regulator', 8, 'New'),
('Diving Suit', 12, 'Used');
GO