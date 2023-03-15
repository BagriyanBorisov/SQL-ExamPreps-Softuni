CREATE DATABASE [Service]

GO

USE [Service]

CREATE TABLE Users (
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(50) NOT NULL,
[Name] VARCHAR(50),
Birthdate DATETIME,
Age INT CHECK(Age BETWEEN 14 AND 110),
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL)


CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(25),
LastName VARCHAR(25),
BirthDate DATETIME,
Age INT CHECK(Age BETWEEN 18 AND 110),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories (
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
)

CREATE TABLE [Status] (
Id INT PRIMARY KEY IDENTITY,
[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports(
Id INT PRIMARY KEY IDENTITY,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
OpenDate DATETIME NOT NULL,
CloseDate DATETIME,
[Description] VARCHAR(200) NOT NULL,
UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)

)

--problem 2 insert
INSERT INTO Employees(FirstName,LastName,Birthdate, DepartmentId) VALUES 
('Marlo', 'O''Malley', '1958-9-21', 1), 
('Niki', 'Stanaghan', '1969-11-26', 4), 
('Ayrton', 'Senna', '1960-03-21', 9), 
('Ronnie', 'Peterson', '1944-02-14', 9), 
('Giovanna', 'Amati', '1959-06-20', 5)


INSERT INTO Reports(CategoryId,StatusId, OpenDate, CloseDate,Description,UserId, EmployeeId) VALUES
( 1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
( 6, 3, '2015-09-05', '2015-12-06','Charity trail running', 10, NULL),
( 14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
( 4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--probleme 3 update
UPDATE Reports
	SET CloseDate = GETDATE()
 WHERE CloseDate IS NULL

--problem 4 delete
DELETE FROM Reports WHERE StatusId = 4

--problem 05 queries
SELECT [Description], FORMAT(OpenDate, 'dd-MM-yyyy') FROM Reports WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

--problem 06 queries
SELECT r.[Description],
	   c.[Name] AS CategoryName 
	   FROM Reports AS r
JOIN Categories AS c
ON r.CategoryId = c.Id
WHERE CategoryId IS NOT NULL
ORDER BY r.[Description],c.[Name]

--problem 07 queries
SELECt TOP(5) c.[Name],COUNT(c.Id) AS ReportsNumber FROM Reports as r
JOIN Categories as c
ON c.Id = r.CategoryId
GROUP BY c.[Name]
ORDER BY ReportsNumber DESC,c.[Name]


SELECT u.Username,c.[Name] AS CategoryName FROM Reports as r
JOIN Users as u ON u.Id = r.UserId
JOIN Categories as c ON c.Id = r.CategoryId
WHERE MONTH(u.Birthdate) = MONTH(r.OpenDate) AND DAY(u.Birthdate) = DAY(r.OpenDate)
ORDER BY u.Username, CategoryName


--problem 09 queries
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName
	  ,Count(r.UserId) as UsersCount FROM Employees as e
LEFT JOIN Reports as r on e.Id = r.EmployeeId
GROUP BY e.FirstName,e.LastName,e.Id
ORDER BY UsersCount DESC, FullName


--Problem 10 full info
SELECT CASE WHEN e.FirstName iS NULL THEN 'None'
	        WHEN e.FirstName iS NOT NULL THEN CONCAT(e.FirstName, ' ', e.LastName)
	   END AS Employee,
	   ISNULL(d.[Name],'None') AS Department,
	   c.[Name] AS Category,
	   r.[Description],
	   FORMAT(r.OpenDate,'dd.MM.yyyy') AS OpenDate,
	   s.[Label] AS [Status],
	   u.[Name] as [User] FROM Reports as r
LEFT JOIN Employees as e ON e.Id = r.EmployeeId
JOIN Categories as c on c.Id = r.CategoryId
JOIN Users as u on u.Id = r.UserId
LEFT JOIN Departments as d on d.Id = e.DepartmentId
JOIN [Status] as s on s.Id = r.StatusId
ORDER BY e.FirstName DESC, e.LastName,Department,Category
		,r.[Description],OpenDate,s.[Label],u.[Name]
