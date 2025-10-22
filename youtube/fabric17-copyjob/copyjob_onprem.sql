/*
	Copy job
	* On-Prem script

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/

USE AdventureWorks2022
GO

SELECT * FROM [Person].[Person]



-- Demo 2

SELECT * FROM Sales.SalesOrderHeader

SELECT * FROM Sales.SalesOrderDetail


SELECT * FROM Sales.SalesOrderHeader

-- instrukcja wstawiająca 3 zamówienia
INSERT INTO Sales.SalesOrderHeader
(    RevisionNumber,    OrderDate,    DueDate,    ShipDate,    Status,    OnlineOrderFlag,    PurchaseOrderNumber,    AccountNumber,
    CustomerID,    SalesPersonID,    TerritoryID,    BillToAddressID,    ShipToAddressID,    ShipMethodID,    CreditCardID,    CreditCardApprovalCode,    CurrencyRateID,
    SubTotal,    TaxAmt,    Freight,    Comment,    rowguid,    ModifiedDate)
VALUES
(1, GETDATE(), DATEADD(DAY, 7, GETDATE()), DATEADD(DAY, 2, GETDATE()),
 5, 1, 'PO12345', '10-4020-000000', 29825, 279, 5, 919, 919, 5, 16281, 'APPROVED', NULL, 1000.00, 80.00, 50.00, 'Test order 1', NEWID(), GETDATE()),
(1, GETDATE(), DATEADD(DAY, 10, GETDATE()), DATEADD(DAY, 3, GETDATE()),
 5, 1, 'PO12346', '10-4020-000001', 29825, 279, 5, 919, 919, 5, 16281, 'APPROVED', NULL, 2500.00, 200.00, 100.00, 'Test order 2', NEWID(), GETDATE()),
(1, GETDATE(), DATEADD(DAY, 14, GETDATE()), DATEADD(DAY, 4, GETDATE()),
 5, 1, 'PO12347', '10-4020-000002', 29825, 279, 5, 919, 919, 5, 16281, 'APPROVED', NULL, 500.00, 40.00, 25.00, 'Test order 3', NEWID(), GETDATE());


 -- XEvent Profiler

 SELECT MAX("ModifiedDate") AS "nextCheckpoint" FROM "Sales"."SalesOrderDetail"
 SELECT MAX("ModifiedDate") AS "nextCheckpoint" FROM "Sales"."SalesOrderHeader" -- tu są nowe wiersze

 -- zapytanie zwracające nowe wiersze
SELECT * FROM "Sales"."SalesOrderHeader" WHERE "ModifiedDate" <= '2025-10-20T21:01:47.957' AND "ModifiedDate" > '2014-07-07T00:00:00Z'
SELECT * FROM "Sales"."SalesOrderDetail" WHERE "ModifiedDate" <= '2014-06-30T00:00:00' AND "ModifiedDate" > '2014-06-30T00:00:00Z'



-- instrukcja modyfikująca 2 zamówienia

UPDATE Sales.SalesOrderHeader
SET 
    Comment = 'Zaktualizowano dane klienta – ponowna weryfikacja adresu.',
    Freight = Freight * 1.10,  -- zwiększenie kosztu transportu o 10%
    ModifiedDate = GETDATE()
WHERE SalesOrderID = 43659;

UPDATE Sales.SalesOrderHeader
SET 
    Comment = 'Aktualizacja statusu – pilna wysyłka ekspresowa.',
    ShipDate = DATEADD(DAY, -1, ShipDate),  -- wysyłka dzień wcześniej
    ModifiedDate = GETDATE()
WHERE SalesOrderID = 43660;

SELECT * FROM Sales.SalesOrderHeader WHERE SalesOrderID IN (43659, 43660)



-- > Notebook: 
-- DELETE FROM Sales.SalesOrderHeader


-- ponowna modyfikacja
UPDATE Sales.SalesOrderHeader
SET 
    Comment = 'Aktualizacja statusu – pilna wysyłka!!!',
    ShipDate = DATEADD(DAY, -1, ShipDate),  -- wysyłka dzień wcześniej
    ModifiedDate = GETDATE()
WHERE SalesOrderID = 43660;



-- > Reset tabeli w Copy job
