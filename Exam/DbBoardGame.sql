CREATE DATABASE Boardgames

USE BoardGames

CREATE TABLE Categories (
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses (
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100) NOT NULL,
StreetNumber INT  NOT NULL,
Town VARCHAR(30) NOT NULL,
Country VARCHAR(50) NOT NULL,
ZIP INT NOT NULL
)

CREATE TABLE Publishers(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) UNIQUE NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
Website NVARCHAR(40),
Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges(
Id INT PRIMARY KEY IDENTITY,
PlayersMin INT NOT NULL,
PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames (
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
YearPublished INT NOT NULL,
Rating DECIMAL(18,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id)NOT NULL,
PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)


CREATE TABLE Creators (
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames (
CreatorId INT FOREIGN KEY REFERENCES Creators(Id) ,
BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id),
PRIMARY KEY (CreatorId, BoardgameId)
)


--Problem 2
INSERT INTO Publishers  ([Name], AddressId, Website,Phone) VALUES 
('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')


INSERT INTO Boardgames ([Name], YearPublished, Rating, CategoryId, PublisherId, PlayersRangeId) VALUES
('Deep Blue', 2019, 5.67, 1, 15, 7),
( 'Paris', 2016, 9.78, 7, 1, 5),
('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
( 'Bleeding Kansas', 2020, 3.25, 3, 7, 4),
('One Small Step', 2019, 5.75, 5, 9, 2)

--problem 3
UPDATE PlayersRanges
SET PlayersMax = 3
WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= 2020

--problem 4
DELETE FROM CreatorsBoardgames WHERE BoardgameId = 1 OR BoardgameId = 16 OR BoardgameId = 31 OR BoardgameId = 47
DELETE FROM Boardgames WHERE PublisherId = 1 OR PublisherId = 16
DELETE FROM Publishers WHERE AddressId = 5
DELETE FROM Addresses WHERE Town LIKE 'L%';


--problem 5
SELECT [Name], Rating FROM Boardgames ORDER BY YearPublished, [Name] DESC


--problem 6
SELECT b.Id, b.[Name], b.YearPublished, c.[Name] AS CategoryName
FROM Boardgames as b
JOIN Categories as c ON c.Id = b.CategoryId
WHERE c.[Name] = 'Strategy Games' OR c.[Name] = 'Wargames'
ORDER BY b.YearPublished DESC

--problem 7
SELECT c.Id, CONCAT(c.FirstName, ' ', c.LastName) AS CreatorName, c.Email
FROM Creators as c
LEFT JOIN CreatorsBoardgames as cb 
ON cb.CreatorId = c.Id
WHERE cb.CreatorId IS NULL
ORDER BY CreatorName 

--problem 8
SELECT TOP(5) b.[Name],b.Rating, c.[Name] AS CategoryName 
FROM Boardgames as b
JOIN PlayersRanges as p 
on p.Id = b.PlayersRangeId
JOIN Categories as c  
on c.Id = b.CategoryId
WHERE (b.Rating > 7.00 AND b.[Name] LIKE '%a%') OR 
(b.Rating > 7.50 AND p.PlayersMin = 2 AND p.PlayersMax = 5)
ORDER BY b.[Name], b.Rating DESC


--problem 9 
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS FullName, c.Email, MAX(b.Rating ) AS Rating
FROM Creators as c
JOIN CreatorsBoardgames as cb 
ON c.Id = cb.CreatorId
JOIN Boardgames as b
ON b.Id = cb.BoardgameId
WHERE c.Email LIKE '%.com'
GROUP BY c.FirstName, c.LastName,c.Email
ORDER BY FullName

--problm 10
SELECT  c.LastName,CEILING(AVG(b.Rating )) AS AverageRating, p.[Name] AS PublisherName
FROM Creators as c
JOIN CreatorsBoardgames as cb 
ON c.Id = cb.CreatorId
JOIN Boardgames as b
ON b.Id = cb.BoardgameId
JOIN Publishers as p
ON p.Id = b.PublisherId
WHERE p.[Name] = 'Stonemaier Games'
GROUP BY c.LastName,p.[Name]
ORDER BY AVG(b.Rating) DESC

--problem 11
CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
Declare @cId AS INT
SET @cId= (SELECT Id FROM Creators WHERE FirstName = @name)
	RETURN (SELECT COUNT(*) FROM CreatorsBoardgames WHERE CreatorId = @cId)
END


--problem12
CREATE PROCEDURE usp_SearchByCategory(@category VARCHAR(50)) AS
SELECT b.[Name], 
	   b.YearPublished, 
	   b.Rating, 
	   c.[Name] AS CategoryName,
	   p.[Name] AS PublisherName,
	   CONCAT(pr.PlayersMin, ' ', 'people') as MinPlayers,
	   CONCAT(pr.PlayersMax, ' ', 'people') AS MaxPlayers
FROM Boardgames as b
JOIN Categories as c on c.Id = b.CategoryId
JOIN Publishers as p on p.Id = b.PublisherId
JOIN PlayersRanges as pr on pr.Id = b.PlayersRangeId
WHERE c.[Name] = @category
ORDER BY PublisherName, b.YearPublished DESC


EXEC usp_SearchByCategory 'Wargames'