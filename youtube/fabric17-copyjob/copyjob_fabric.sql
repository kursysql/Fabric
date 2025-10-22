/*
	Copy job
	* Fabric Script

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/

SELECT * FROM Person.Person

SELECT count(*) FROM dbo.Person_Person

SELECT count(*) FROM Person.EmailAddress
SELECT count(*) FROM Person.Password
SELECT count(*) FROM Person.Person
SELECT count(*) FROM Person.PersonPhone


SELECT * FROM Person.PersonPhone



SELECT * FROM Person.Person

SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName
FROM Person.Person
ORDER BY 1

-- Sales
-- Incremental

-- 31 465
SELECT count(*) FROM Sales.SalesOrderHeader 




-- 31 468
SELECT count(*) FROM Sales.SalesOrderHeader 

-- po wstawieniu 3 wierszy
SELECT Comment, ModifiedDate, *  FROM Sales.SalesOrderHeader ORDER BY SalesOrderID DESC

-- po modyfikacji 2 wierszy
SELECT Comment, ModifiedDate, * FROM Sales.SalesOrderHeader WHERE SalesOrderID IN (43659, 43660)





