USE Netflox

-- No 1
SELECT [Name] = CONCAT(FirstName, ' ', LastName),
[CustAddres] = CONCAT(Address, ',', City)
FROM MsCustomer
ORDER BY DOB

-- No 2
SELECT [Staff] = CONCAT(RIGHT(StaffID, 3), ' - ', lastName),
Email, Gender
FROM MsStaff
WHERE Salary > 1600000

-- No 3
CREATE VIEW vw_Q3OrderList
AS
	SELECT [Customer Name] = CONCAT(MSC.FirstName, ' ', MSC.LastName),
	[Order Date] = CONVERT(VARCHAR, TRO.OrderDate, 105),
	TROD.RentalDuration
	FROM TrOrder TRO
	JOIN MsCustomer MSC ON TRO.CustomerID = MSC.CustomerID
	JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
	WHERE YEAR(TRO.OrderDate) = 2021 AND DATEPART(month, TRO.OrderDate) BETWEEN '07' AND '09'

SELECT * FROM vw_Q3OrderList
-- DROP VIEW vw_Q3OrderList

-- No 4
SELECT [Title] = REPLACE(MSF.Title, SUBSTRING(MSF.Title, CHARINDEX(' ', MSF.Title)+1, LEN(MSF.Title)), MSG.GenreName),
[Film Details] = CONVERT(VARCHAR, YEAR(MSF.ReleaseDate)) + ' : ' + MSF.Director
FROM MsFilms MSF
JOIN MsGenre MSG ON MSF.GenreID = MSG.GenreID
JOIN MsRegion MSR ON MSF.RegionID = MSR.RegionID
WHERE MSF.Title LIKE '% %' AND MSR.RegionName LIKE 'Europe'

-- No 5
SELECT [Customer Name] = 
CONCAT(
	CASE
		WHEN MSC.Gender = 'M' THEN 'Mr. '
		ELSE 'Ms. '
	END, 
	MSC.FirstName, ' ', MSC.LastName
),
[Order Date] = CONVERT(VARCHAR, TRO.OrderDate, 110),
MSF.Title
FROM TrOrder TRO
JOIN MsCustomer MSC ON TRO.CustomerID = MSC.CustomerID
JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
JOIN MsFilms MSF ON TROD.FilmID = MSF.FilmID
JOIN MsPayment MSP ON TRO.PaymentMethodID = MSP.PaymentMethodID
WHERE MSP.PaymentMethodName LIKE 'E-Wallet'

-- No 6
SELECT [Gender] = CONCAT(
	CASE
		WHEN Gender = 'M' THEN 'Male '
		ELSE 'Female '
	END, 'Staff'
),
[Total Salary] = 'Rp. ' + CAST(SUM(Salary) AS VARCHAR) + ',-'
FROM MsStaff
GROUP BY Gender

-- No 7
SELECT [Title] = LEFT(MSR.RegionName, 2) + ' ' + MSF.Title,
[Synopsis] = REVERSE(SUBSTRING(REVERSE(MSF.Director), 0, CHARINDEX(' ', REVERSE(MSF.Director)))) + ' ' + MSF.Synopsis,
MSF.ReleaseDate
FROM MsFilms MSF
JOIN MsRegion MSR ON MSF.RegionID = MSR.RegionID
JOIN MsGenre MSG ON MSF.GenreID = MSG.GenreID
WHERE MSG.GenreName LIKE 'Horror'

-- No 8
SELECT DISTINCT [Customer Name] = LOWER(CONCAT(MSC.FirstName, ' ', MSC.LastName)),
[Order Count] = COUNT(DISTINCT TRO.OrderID),
[Film Count] = COUNT(TROD.RentalDuration)
FROM TrOrder TRO
JOIN MsCustomer MSC ON TRO.CustomerID = MSC.CustomerID
JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
WHERE YEAR(TRO.OrderDate) = 2021 AND MONTH(TRO.OrderDate) BETWEEN 02 AND 12
GROUP BY MSC.FirstName, MSC.LastName
ORDER BY COUNT(TROD.RentalDuration) ASC, LOWER(CONCAT(MSC.FirstName, ' ', MSC.LastName)) DESC

-- No 9
SELECT [Customer Name] = CONCAT(MSC.FirstName, ' ', MSC.LastName),
[Customer Order Time] = CONVERT(VARCHAR, CAST(TRO.OrderDate AS time), 0),
[Total Rental Duration] = SUM(TROD.RentalDuration)
FROM TrOrder TRO
JOIN MsCustomer MSC ON TRO.CustomerID = MSC.CustomerID
JOIN MsStaff MSS ON TRO.StaffID = MSS.StaffID
JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
WHERE MSS.LastName IN ('Sitorus', 'Haryanti')
GROUP BY MSC.FirstName, MSC.LastName, TRO.OrderDate
ORDER BY MSC.FirstName

-- No 10
SELECT [Customer Name] = CONCAT(MSC.FirstName, ' ', MSC.LastName),
[Customer Gender] =
CASE
	WHEN MSC.Gender = 'M' THEN 'Male'
	ELSE 'Female'
END,
[Total Order Count] = COUNT(DISTINCT TRO.OrderID),
[Average Rental Duration] = AVG(DISTINCT TROD.RentalDuration)
FROM MsCustomer MSC
JOIN TrOrder TRO ON MSC.CustomerID = TRO.CustomerID
JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
JOIN MsFilms MSF ON TROD.FilmID = MSF.FilmID
JOIN MsRegion MSG ON MSF.RegionID = MSG.RegionID
JOIN MsStaff MSS ON MSS.StaffID = TRO.StaffID
WHERE MSS.LastName = 'Nuraini' AND MSG.RegionName IN ('Asia', 'Africa', 'America')
GROUP BY MSC.FirstName, MSC.LastName, MSC.Gender

-- No 11
CREATE PROCEDURE GetTopFiveFilms
AS
BEGIN
	SELECT TOP 5 MSF.Title,
	MSF.Synopsis,
	MAX(TROD.RentalDuration)
	FROM MsFilms MSF
	JOIN TrOrderDetail TROD ON MSF.FilmID = TROD.FilmID
	GROUP BY MSF.Title, MSF.Synopsis
	ORDER BY MAX(TROD.RentalDuration) DESC, MSF.Title
END
GetTopFiveFilms
-- DROP PROCEDURE GetTopFiveFilms

-- No 12
CREATE PROCEDURE GetYearTotalFilm
AS
BEGIN
	SELECT [FilmYear] = YEAR(TRO.OrderDate),
	[CountData] = COUNT(TRO.OrderDate)
	FROM TrOrder TRO
	GROUP BY YEAR(TRO.OrderDate)
	ORDER BY YEAR(TRO.OrderDate)
END
GetYearTotalFilm
-- DROP PROCEDURE GetYearTotalFilm

-- No 13
CREATE PROCEDURE GetOrderByCustomer
	@input VARCHAR (MAX) = ''
AS
BEGIN
	SELECT TRO.OrderID,
	TRO.OrderDate,
	[CustomerName] = CONCAT(MSC.FirstName, ' ', MSC.LastName),
	MSF.Title,
	TROD.RentalDuration
	FROM MsCustomer MSC
	JOIN TrOrder TRO ON MSC.CustomerID = TRO.CustomerID
	JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
	JOIN MsFilms MSF ON TROD.FilmID = MSF.FilmID
	WHERE MSC.CustomerID = @input
END
GetOrderByCustomer MC001
-- DROP PROCEDURE GetOrderByCustomer

-- No 14
CREATE PROCEDURE GetFilm
	@region VARCHAR (MAX) = NULL,
	@genre VARCHAR (MAX) = NULL
AS
BEGIN
	IF @genre IS NULL
		SELECT MSF.Title,
		MSG.GenreName,
		MSF.ReleaseDate,
		MSF.Synopsis,
		MSF.Director
		FROM MsFilms MSF
		JOIN MsGenre MSG ON MSF.GenreID = MSG.GenreID
		JOIN MsRegion MSR ON MSF.RegionID = MSR.RegionID
		WHERE MSR.RegionName = @region
		ORDER BY MSF.Title

	IF @genre IS NOT NULL
		SELECT MSF.Title,
		MSG.GenreName,
		MSF.ReleaseDate,
		MSF.Synopsis,
		MSF.Director
		FROM MsFilms MSF
		JOIN MsGenre MSG ON MSF.GenreID = MSG.GenreID
		JOIN MsRegion MSR ON MSF.RegionID = MSR.RegionID
		WHERE MSR.RegionName = @region AND MSG.GenreName = @genre
		ORDER BY MSF.Title
END

GetFilm Asia, Horror
GetFilm Asia
-- DROP PROCEDURE GetFilm

-- No 15
CREATE PROCEDURE GetOrderByCode
	@input VARCHAR(MAX) = ''
AS
BEGIN
	SELECT TRO.OrderID,
	TRO.OrderDate,
	MSF.Title,
	[Release Detail] = CAST(YEAR(ReleaseDate) AS VARCHAR) + ' : ' + MSF.Director,
	[RentalDuration] = TROD.RentalDuration
	FROM TrOrder TRO
	JOIN TrOrderDetail TROD ON TRO.OrderID = TROD.OrderID
	JOIN MsFilms MSF ON TROD.FilmID = MSF.FilmID
	WHERE TRO.OrderID = @input OR TROD.OrderDetailID = @input
END
GetOrderByCode TO002
GetOrderByCode OD004
-- DROP PROCEDURE GetOrderByCode

select * from MsCustomer
select * from MsStaff
select * from MsFilms
select * from MsGenre
select * from MsRegion
select * from MsPayment
select * from TrOrder
select * from TrOrderDetail

