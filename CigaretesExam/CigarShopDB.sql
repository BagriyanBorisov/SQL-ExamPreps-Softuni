CREATE DATABASE CigarShop
Go
USE CigarShop

--Problem 1 DDL
CREATE TABLE Sizes (
Id INT PRIMARY KEY IDENTITY,
[Length] INT CHECK([Length] BETWEEN 10 AND 25) NOT NULL,
RingRange DECIMAL (3,2) CHECK (RingRange BETWEEN 1.5 AND 7.5) NOT NULL  
)

CREATE TABLE Tastes (
Id INT PRIMARY KEY IDENTITY,
TasteType VARCHAR(20) NOT NULL,
TasteStrength VARCHAR(15) NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)


CREATE TABLE Brands (
Id INT PRIMARY KEY IDENTITY,
BrandName VARCHAR(30) NOT NULL,
BrandDescription VARCHAR(max)
)


CREATE TABLE Cigars (
Id INT PRIMARY KEY IDENTITY,
CigarName VARCHAR(80) NOT NULL,
BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL, --????
SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
PriceForSingleCigar MONEY NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)


CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
Town VARCHAR(30) NOT NULL,
Country NVARCHAR(30) NOT NULL,
Streat NVARCHAR(100) NOT NULL,
ZIP VARCHAR(20) NOT NULL
)


CREATE TABLE Clients (
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(50) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)


CREATE TABLE ClientsCigars(
ClientId INT FOREIGN KEY REFERENCES Clients(Id),
CigarId INT FOREIGN KEY REFERENCES Cigars(Id),
PRIMARY KEY (ClientId,CigarId)
)


--PROBLEM 2 INSERT
INSERT INTO Cigars (CigarName,BrandId,TastId, SizeId, PriceForSingleCigar, ImageURL) VALUES 
('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50,'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00,'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES', 2, 3, 8, 85.21,'trinidad-coloniales-stick_30.jpg')


INSERT INTO Addresses (Town,Country,Streat, ZIP) VALUES 
('Sofia', 'Bulgaria', '18 Bul. Vasil levski', 1000),
('Athens', 'Greece','4342 McDonald Avenue', 10435 ),
('Zagreb','Croatia','4333 Lauren Drive', 10000 )



--Problem 03 UPDATE
UPDATE Cigars 
SET PriceForSingleCigar = PriceForSingleCigar  *  1.20
WHERE TastId = 1

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

--Problem 04 DELETE
	DELETE c
	  FROM Clients AS c
INNER JOIN Addresses AS a
		ON c.AddressId = a.Id
	 WHERE Country LIKE 'C%';

DELETE From Addresses WHERE Country LIKE 'C%';

--Problem 05 Queries
  SElECT CigarName, PriceForSingleCigar, ImageURL 
    FROM Cigars 
ORDER BY PriceForSingleCigar, CigarName DESC

--PRoblem 06 CigarsBytaste
	SELECT c.Id,
		   c.CigarName,
		   c.PriceForSingleCigar,
		   t.TasteType,
		   t.TasteStrength
	  FROM Cigars
		AS c
INNER JOIN Tastes 
		AS t
		ON c.TastId = t.Id
	 WHERE t.TasteType = 'Earthy' OR t.TasteType = 'Woody'
  ORDER BY c.PriceForSingleCigar DESC


--PRoblem 07 Clients Without cigars
	SELECT 
			c.Id,
			CONCAT(c.FirstName, ' ', c.LastName) AS ClientName,
		    c.Email
	  FROM Clients
		AS c
 LEFT JOIN ClientsCigars
		AS cc 
		ON cc.ClientId = c.Id
	WHERE cc.ClientId IS NULL
	ORDER BY ClientName

--problem 08 First 5 Cigars
	SELECT TOP(5) c.CigarName,
		   c.PriceForSingleCigar,
		   c.ImageURL
	  FROM Cigars
	    AS c
INNER JOIN Sizes
		AS s
		ON c.SizeId = s.Id
	 WHERE s.[Length] >= 12 AND (c.CigarName LIKE '%ci%' OR
		 (c.PriceForSingleCigar > 50 AND s.RingRange > 2.55))
  ORDER BY c.CigarName,c.PriceForSingleCigar DESC

 --Problem 09
	SELECT CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
		   a.Country,
		   a.ZIP,
		   STUFF(MAX(ci.PriceForSingleCigar), 1,0,'$') AS CigarPrice
	  FROM Addresses AS a
INNER JOIN Clients AS c
		ON c.AddressId = a.Id
INNER JOIN ClientsCigars AS cc
		ON cc.ClientId = c.Id
INNER JOIN Cigars AS ci
		ON ci.Id = cc.CigarId 
  GROUP BY c.FirstName, c.LastName, a.Country, a.ZIP
	HAVING ISNUMERIC(a.ZIP) = 1
  ORDER BY FullName

--Problem 10
	SELECT c.LastName,
		   CEILING(AVG(s.[Length])) AS CiagrLength,
		   CEILING(AVG(s.RingRange)) AS CiagrRingRange
	  FROM Clients as c
INNER JOIN ClientsCigars as cc
		ON cc.ClientId= c.Id
INNER JOIN Cigars as ci 
		ON ci.Id = cc.CigarId
INNER JOIN Sizes as s
		ON s.Id = ci.SizeId
	GROUP BY c.LastName
	ORDER BY CiagrLength DESC

