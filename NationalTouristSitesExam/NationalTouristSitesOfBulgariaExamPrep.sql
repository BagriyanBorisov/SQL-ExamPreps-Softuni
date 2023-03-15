CREATE DATABASE NationalTouristSitesOfBulgaria

GO
USE NationalTouristSitesOfBulgaria
--Problem 01
CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL
)

CREATE TABLE Locations (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Municipality VARCHAR(50),
	Province VARCHAR(50)
)


CREATE TABLE Sites (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Establishment VARCHAR(15)
)


CREATE TABLE Tourists (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Age INT NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Reward VARCHAR(20),
	CONSTRAINT Age CHECK (Age BETWEEN 0 AND 120)
)

CREATE TABLE SitesTourists (
TouristId INT FOREIGN KEY REFERENCES Tourists(Id),
SiteId INT FOREIGN KEY REFERENCES Sites(Id),
PRIMARY KEY (TouristId,SiteId)
)

CREATE TABLE BonusPrizes(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes (
TouristId INT FOREIGN KEY REFERENCES Tourists(Id),
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id),
PRIMARY KEY (TouristId,BonusPrizeId)
)


--Problem 02
INSERT INTO Tourists(Name, Age, PhoneNumber, Nationality, Reward) VALUES
('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
('Peter Bosh', 48, '+447911844141', 'UK', NULL),
('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)


INSERT INTO Sites(Name, LocationId, CategoryId, Establishment) VALUES
('Ustra fortress', 90, 7, 'X'),
('Karlanovo Pyramids', 65, 7, NULL),
('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
('Sinite Kamani Natural Park', 17, 1, NULL),
('St. Petka of Bulgaria – Rupite', 92, 6, '1994')


--Problem 03
UPDATE Sites
SET [Establishment] = '(not defined)'
WHERE [Establishment] IS NULL

--Problem 04
DELETE FROM TouristsBonusPrizes WHERE [BonusPrizeId] = 5
DELETE FROM BonusPrizes WHERE Id = 5


--Problem 05
Select [Name],[Age],[PhoneNumber],Nationality FROM Tourists
ORDER BY [Nationality],[Age] DESC,[Name]

--Problem 06 
	SELECT
		[s].[Name] AS [Site],
		[l].[Name] AS [Location],
		[s].[Establishment],
		[c].[Name] AS [Category]
	  FROM Sites
		AS [s]
INNER JOIN Locations
		AS [l]
		ON [s].[LocationId] = [l].Id
INNER JOIN Categories
		AS [c]
		ON [s].CategoryId = [c].Id
ORDER BY [Category] DESC,[Location], [Site]



--Problem 07
SELECT [l].Province,
	   [l].[Municipality],
	   [l].[Name] AS [Location],
	   COUNT([s].LocationId) AS [CountOfSites]
	FROM Sites
		   AS [s]
INNER JOIN Locations
		AS [l]
		ON [s].LocationId = [l].Id AND [l].Province = 'Sofia'
	GROUP BY [l].[Province],[l].Municipality,[l].[Name]
	ORDER BY [CountOfSites] DESC, [Location]



--Problem 08
	SELECT [s].[Name] AS [Site],
		   [l].[Name] AS [Location],
		   [l].Municipality,
		   [l].Province,
		   [s].Establishment
	  FROM Sites
		AS [s]
INNER JOIN Locations
		AS [l]
		ON [s].LocationId = [l].Id
     WHERE [l].[Name] LIKE '[^MBD]%' AND [s].Establishment LIKE '%BC'
  ORDER BY [Site]



--Problem 09
	SELECT [t].[Name],
		   [t].Age,
		   [t].PhoneNumber,
		   [t].Nationality,
		   ISNULL([bp].[Name], '(no bonus prize)') AS [Reward]
	  FROM Tourists
		AS [t]
 LEFT JOIN TouristsBonusPrizes
		AS [tbp]
		ON [t].Id = [tbp].TouristId
 LEFT JOIN BonusPrizes
		AS [bp]
		ON [bp].Id = [tbp].BonusPrizeId
  ORDER BY [t].[Name]


--Problem 10
	SELECT DISTINCT SUBSTRING([t].[Name], CHARINDEX(' ',[t].[Name]) + 1, LEN([t].[Name])) AS [LastName],
		   [t].Nationality,
		   [t].Age,
		   [t].PhoneNumber
	  FROM Tourists
		AS [t]
INNER JOIN SitesTourists
		AS [st]
		ON [t].Id = [st].TouristId
INNER JOIN Sites 
		AS [s]
		ON [s].Id = [st].SiteId
INNER JOIN Categories
		AS [c]
		ON [s].CategoryId = [c].Id
	 WHERE [c].Id = 8
  ORDER BY [LastName]


--Problem 11
CREATE FUNCTION [udf_GetTouristsCountOnATouristSite] (@Site VARCHAR(100))
	RETURNS INT
			 AS
		  BEGIN
		DECLARE @siteId INT;
			SET @siteId = ( SELECT [Id] FROM Sites WHERE [Name] = @Site );
		DECLARE @touristsCount INT;
			SET @touristsCount = ( SELECT COUNT(*) FROM SitesTourists WHERE [SiteId] = @siteId)
		 RETURN @touristsCount;
			END

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')


--Problem 12
CREATE PROCEDURE usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
BEGIN
DECLARE @touristId INT;
SET @touristId = (SELECT [Id] FROM Tourists WHERE [Name] = @TouristName)
DECLARE @count INT;
SET @count = (SELECT COUNT(*) FROM SitesTourists WHERE TouristId = @touristId)
UPDATE Tourists 
SET Reward =  CASE  
                        WHEN @count >= 100 THEN 'Gold badge' 
                        WHEN @count >=50 THEN 'Silver badge' 
                        WHEN @count >= 25 THEN 'Bronze badge'
						ELSE Reward
                    END
	 WHERE [Name] = @TouristName
SELECT [Name],[Reward] FROM Tourists WHERE [Name] = @TouristName
END


EXEC usp_AnnualRewardLottery 'Gerhild Lutgard'
EXEC usp_AnnualRewardLottery 'Teodor Petrov'
EXEC usp_AnnualRewardLottery 'Zac Walsh'

