CREATE DATABASE Airport
GO

USE Airport

--Problem 01 DDL
CREATE TABLE Passengers (
		Id INT PRIMARY KEY IDENTITY,
		FullName VARCHAR(100) NOT NULL,
		Email VARCHAR(50) NOT NULL
)

CREATE TABLE Pilots (
		Id INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(30) NOT NULL,
		LastName VARCHAR(30) NOT NULL,
		Age TINYINT NOT NULL,
		Rating FLOAT,
		CONSTRAINT Age CHECK (Age BETWEEN 0 AND 120),
		CONSTRAINT Rating CHECK (Rating BETWEEN 0.0 AND 10.0)
)


CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) UNIQUE NOT NULL
)


CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR NOT NULL,
	TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
	PRIMARY KEY (AircraftId,PilotId)
)

CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) NOT NULL UNIQUE,
	Country VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE FlightDestinations (
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
	[Start] DATETIME NOT NULL,
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	TicketPrice DECIMAL(18,2) NOT NULL DEFAULT 15.00
)


--Problem 02 Insert
INSERT INTO Passengers(FullName, Email) (
	SELECT CONCAT_WS(' ',FirstName,LastName), 
			CONCAT(FirstName,LastName,'@gmail.com')
	FROM Pilots WHERE Id >= 5 AND Id <=15 
)

--Problem 03 Update
UPDATE Aircraft
   SET Condition = 'A'
	WHERE [Year] >= 2013 
		AND (FlightHours IS NULL OR FlightHours <= 100)
		AND (Condition = 'C' OR Condition = 'B')



--Problem 04 Delete
DELETE FROM Passengers WHERE LEN(FullName) <= 10

--Problem 05 AircraftQuery
SELECT [Manufacturer],[Model],[FlightHours],Condition FROM Aircraft
ORDER BY FlightHours DESC

--Problem 06 PilotsAndAircraft
	SELECT [p].FirstName,
		   [p].LastName,
		   [a].Manufacturer,
		   [a].Model,
		   [a].FlightHours
	  FROM Pilots
		AS [p]
INNER JOIN PilotsAircraft
		AS [pa]
		ON [p].Id = [pa].PilotId
INNER JOIN Aircraft 
		AS [a]
		ON [a].Id = [pa].AircraftId
	 WHERE [a].FlightHours BETWEEN 0 AND 303
  ORDER BY [a].FlightHours DESC,[p].FirstName


 --Problem 07 top20FlightD
	SELECT TOP(20) [fd].Id,
		   [fd].[Start],
		   [p].FullName,
		   [a].AirportName,
		   [fd].TicketPrice
	  FROM FlightDestinations
		AS [fd]
INNER JOIN Passengers
		AS [p]
		ON [p].Id = [fd].PassengerId
INNER JOIN Airports
		AS [a]
		ON [a].Id = [fd].AirportId
	 WHERE DAY([fd].[Start]) % 2 = 0
  ORDER BY [fd].TicketPrice DESC, [a].AirportName


--PRoblem 08 NumberOfFlightsForEachAircraft
	SELECT [fd].AircraftId,
		   [a].Manufacturer,
		   [a].FlightHours,
		   COUNT([fd].AircraftId) AS [FlightDestinationsCount],
		   ROUND(AVG([fd].TicketPrice), 2) AS [AvgPrice]
	  FROM Aircraft  
		AS [a]
INNER JOIN FlightDestinations
		AS [fd]
		ON [a].Id = [fd].AircraftId
  GROUP BY [a].[Manufacturer],[fd].AircraftId, [a].FlightHours
	HAVING COUNT([fd].AircraftId) > 1
  ORDER BY FlightDestinationsCount DESC,[fd].AircraftId
  


--Problem 09 RegularPassengers
	SELECT [p].FullName,
		   COUNT([fd].PassengerId) AS [CountOfAircraft],
		   SUM([fd].TicketPrice) AS [TotalPayed]
	  FROM Passengers
		AS [p]
INNER JOIN FlightDestinations
		AS [fd]
		ON [p].Id = [fd].PassengerId
  GROUP BY [p].[FullName],[fd].PassengerId
	HAVING COUNT([fd].PassengerId) > 1 AND PATINDEX('%a%', [p].FullName) = 2
  ORDER BY [p].FullName


--Problem 10 FullInfoForFlightDest
	SELECT [a].AirportName,
		   [fd].[Start] AS [DayTime],
		   [fd].TicketPrice,
		   [p].FullName,
		   [ac].Manufacturer,
		   [ac].Model
	  FROM FlightDestinations
		AS [fd]
INNER JOIN Airports
		AS [a]
		ON [a].Id = [fd].AirportId
INNER JOIN Passengers
		AS [p]
		ON [p].Id = [fd].PassengerId
INNER JOIN Aircraft
		AS [ac]
		ON [ac].Id= [fd].AircraftId
	 WHERE DATEPART(HH, [Start]) >= 6 AND DATEPART(HH, [Start]) <= 20 AND [TicketPrice] > 2500
  ORDER BY [ac].Model


























