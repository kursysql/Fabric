/*

	Fabric Zero-ETL
	COPY JOB

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
	http://www.kursyfabric.pl
    http://www.youtube.com/c/KursySQL

*/



/*
	1. Połączenie Fabric do Azure SQL Database

	1.1 Utworzenie service principal w Azure AD: sp-zeroetl-copyjob
		- Application (client) ID - Service principal ID 
		- Directory (tenant) ID - Tenant ID 
	1.2 Client Secret 
	1.3 Zapisanie w Key Vault
	1.4 Baza SQL - uprawnienia dla Service Principal
*/


 
--> connect to master

CREATE LOGIN [sp-zeroetl-copyjob] FROM EXTERNAL PROVIDER;

SELECT *FROM sys.server_principals WHERE name = 'sp-zeroetl-copyjob';


--> connect to AdventureWorks_CDC

CREATE USER [sp-zeroetl-copyjob] FOR LOGIN [sp-zeroetl-copyjob];

SELECT * FROM sys.database_principals WHERE name = 'sp-zeroetl-copyjob';


GRANT SELECT TO [sp-zeroetl-copyjob];

SELECT * FROM sys.database_permissions WHERE grantee_principal_id = USER_ID('sp-zeroetl-copyjob');




/*	
	2. Utworzenie połączenia w Fabric do bazy SQL

	conn_zeroetl_azuresql_cdc
*/



/*
	3. Copy Job #1 - Watermark + Merge

	3.1 Konfiguracja Copy Job - cj_zeroetl_watermark
	3.2 Pierwsze uruchomienie - Full Load

*/


SELECT * FROM SalesLT.SalesOrderDetail
SELECT * FROM SalesLT.SalesOrderHeader 



--> Fabric - ZeroETL - SalesLT 


SELECT * FROM SalesLT.SalesOrderDetail
SELECT * FROM SalesLT.SalesOrderHeader 



/*

	3.3. Kolejne uruchomienie bez zmian
	3.4. Uruchomienie po zmianach w tabeli

*/





-- Wstawienie 3 zamówień

DECLARE @CustomerID int = (SELECT TOP 1 CustomerID FROM SalesLT.Customer ORDER BY CustomerID);

INSERT INTO SalesLT.SalesOrderHeader
(
    RevisionNumber,  OrderDate,  DueDate,  ShipDate,  Status,  OnlineOrderFlag,  PurchaseOrderNumber,
    AccountNumber,  CustomerID,  ShipMethod,  CreditCardApprovalCode,  SubTotal,  TaxAmt,  Freight,
    Comment,  rowguid,  ModifiedDate
)
VALUES
(1, GETDATE(), DATEADD(DAY, 7, GETDATE()), DATEADD(DAY, 2, GETDATE()),
 5, 1, 'PO-ZEROETL-001', '10-4020-000000', @CustomerID, 'CARGO TRANSPORT 5', 'APPROVED',
 1000.00, 80.00, 50.00, 'Test order 1', NEWID(), GETDATE()),

(1, GETDATE(), DATEADD(DAY, 10, GETDATE()), DATEADD(DAY, 3, GETDATE()),
 5, 1, 'PO-ZEROETL-002', '10-4020-000001', @CustomerID, 'CARGO TRANSPORT 5', 'APPROVED',
 2500.00, 200.00, 100.00, 'Test order 2', NEWID(), GETDATE()),

(1, GETDATE(), DATEADD(DAY, 14, GETDATE()), DATEADD(DAY, 4, GETDATE()),
 5, 1, 'PO-ZEROETL-003', '10-4020-000002', @CustomerID, 'CARGO TRANSPORT 5', 'APPROVED',
 500.00, 40.00, 25.00, 'Test order 3', NEWID(), GETDATE());


-- Modyfikacja jednego z wstawionych zamówień
UPDATE SalesLT.SalesOrderHeader
SET
    Comment = N'Zero-ETL Watermark - UPDATE',
    Freight = 25.00,
    ModifiedDate = GETUTCDATE()
WHERE PurchaseOrderNumber = N'PO-ZEROETL-001';



-- Weryfikacja
SELECT SalesOrderID, PurchaseOrderNumber, CustomerID,
       SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
FROM SalesLT.SalesOrderHeader
WHERE PurchaseOrderNumber LIKE 'PO-ZEROETL-%'
ORDER BY SalesOrderID DESC;




/*
	3.5 Uruchomienie po skasowaniu wiersza
*/


DELETE FROM SalesLT.SalesOrderHeader 
WHERE PurchaseOrderNumber = N'PO-ZEROETL-001';

-- Weryfikacja
SELECT SalesOrderID, PurchaseOrderNumber, CustomerID,
       SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
FROM SalesLT.SalesOrderHeader
WHERE PurchaseOrderNumber LIKE 'PO-ZEROETL-%'
ORDER BY SalesOrderID DESC;




/*
	4. Copy Job #3 - CDC + Merge (SCD Type 1)

	cj_zeroetl_cdc

	4.1 Konfiguracja CDC w bazie źródłowej
	
*/

IF (SELECT is_cdc_enabled FROM sys.databases WHERE database_id = DB_ID()) = 0
    EXEC sys.sp_cdc_enable_db;

IF NOT EXISTS(SELECT * FROM cdc.change_tables WHERE source_object_id = OBJECT_ID(N'SalesLT.Product'))
	EXEC sys.sp_cdc_enable_table
		@source_schema = N'SalesLT',
		@source_name = N'Product',
		@role_name = NULL,
		@supports_net_changes = 1;

SELECT
    capture_instance,
    supports_net_changes,
    start_lsn
FROM cdc.change_tables
WHERE source_object_id = OBJECT_ID(N'SalesLT.Product');



/*
	4.2 Konfiguracja Copy Job - cj_zeroetl_cdc
	4.3 Pierwsze uruchomienie
	4.4 Kolejne uruchomienie bez zmian
	4.5 Uruchomienie po zmianach w tabeli
*/


INSERT INTO SalesLT.Product
(Name, ProductNumber, StandardCost, ListPrice, SellStartDate, ModifiedDate)
VALUES 
	(N'Zero-ETL CDC Merge1', N'ZEROETL-CJ-MERGE1', 100.00, 150.00, GETUTCDATE(), GETUTCDATE()),
	(N'Zero-ETL CDC Merge2', N'ZEROETL-CJ-MERGE2', 200.00, 250.00, GETUTCDATE(), GETUTCDATE()),
	(N'Zero-ETL CDC Merge3', N'ZEROETL-CJ-MERGE3', 300.00, 350.00, GETUTCDATE(), GETUTCDATE());

SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-MERGE%';

UPDATE SalesLT.Product
SET ListPrice = 275.00, ModifiedDate = GETUTCDATE() 
WHERE ProductNumber = N'ZEROETL-CJ-MERGE1';



-- weryfikacja
SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-MERGE%';



--> cj_zeroetl_cdc


/*
	4.6 Uruchomienie po skasowaniu wiersza
*/


SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-MERGE%';

DELETE FROM SalesLT.Product
WHERE ProductNumber = N'ZEROETL-CJ-MERGE2';

-- weryfikacja
SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-MERGE%';






/*
	5. Copy Job #2 - CDC + + Merge (SCD Type 2)

	5.1 Konfiguracja Copy Job - cj_zeroetl_cdc2
	5.2 Pierwsze uruchomienie
	5.3 Wstawienie nowych wierszy do tabeli źródłowej
	
*/

INSERT INTO SalesLT.Product
(Name, ProductNumber, StandardCost, ListPrice, SellStartDate, ModifiedDate)
VALUES 
	(N'Zero-ETL CDC SCD2_1', N'ZEROETL-CJ-SCD2_1', 100.00, 100.00, GETUTCDATE(), GETUTCDATE()),
	(N'Zero-ETL CDC SCD2_2', N'ZEROETL-CJ-SCD2_2', 200.00, 250.00, GETUTCDATE(), GETUTCDATE()),
	(N'Zero-ETL CDC SCD2_3', N'ZEROETL-CJ-SCD2_3', 300.00, 350.00, GETUTCDATE(), GETUTCDATE());

SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-SCD2%';


--> cj_zeroetl_cdc2


/*
	5.4 Modyfikacja wstawionych wierszy 
*/


-- 100 -> 110
UPDATE SalesLT.Product
SET ListPrice = 110.00, ModifiedDate = GETUTCDATE() 
WHERE ProductNumber = N'ZEROETL-CJ-SCD2_1';

-- 110 -> 120
UPDATE SalesLT.Product
SET ListPrice = 120.00, ModifiedDate = GETUTCDATE() 
WHERE ProductNumber = N'ZEROETL-CJ-SCD2_1';

-- 120 -> 130
UPDATE SalesLT.Product
SET ListPrice = 130.00, ModifiedDate = GETUTCDATE() 
WHERE ProductNumber = N'ZEROETL-CJ-SCD2_1';

UPDATE SalesLT.Product
SET ListPrice = 299.00, ModifiedDate = GETUTCDATE() 
WHERE ProductNumber = N'ZEROETL-CJ-SCD2_2';

DELETE FROM SalesLT.Product
WHERE ProductNumber = N'ZEROETL-CJ-SCD2_3';



SELECT ProductID, ProductNumber, Name, ListPrice
FROM SalesLT.Product WHERE ProductNumber LIKE N'ZEROETL-CJ-SCD2%';




--> cj_zeroetl_cdc2







/*
    Cleanup - Watermark Demo
*/

-- Usunięcie zamówień demonstracyjnych
DELETE FROM SalesLT.SalesOrderHeader
WHERE PurchaseOrderNumber IN ('PO-ZEROETL-001', 'PO-ZEROETL-002', 'PO-ZEROETL-003');

-- Przywrócenie numeracji sekwencji
DECLARE @NextID varchar(10);
SELECT @NextID = ISNULL(MAX(SalesOrderID), 0) + 1 FROM SalesLT.SalesOrderHeader;
EXEC ('ALTER SEQUENCE SalesLT.SalesOrderNumber RESTART WITH ' + @NextID);




-- Usunięcie produktów demonstracyjnych
DELETE FROM SalesLT.Product WHERE ProductNumber LIKE 'ZEROETL-CJ-MERGE%'

DELETE FROM SalesLT.Product WHERE ProductNumber LIKE 'ZEROETL-CJ-SCD2_%'


-- Przywrócenie numeracji IDENTITY
DECLARE @LastID int;
SELECT @LastID = MAX(ProductID) FROM SalesLT.Product;
DBCC CHECKIDENT ('SalesLT.Product', RESEED, @LastID);


