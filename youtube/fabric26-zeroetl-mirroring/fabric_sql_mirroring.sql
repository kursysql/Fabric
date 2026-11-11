/*

	Fabric Zero-ETL
	MIRRORING

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
	http://www.kursyfabric.pl
    http://www.youtube.com/c/KursySQL

*/




/*
	1. Managed Identity serwera Azure SQL
*/

SELECT *
FROM sys.dm_server_managed_identities;




/*
	2.4. Service Principal i uprawnienia
*/



--> connect to master

CREATE LOGIN [sp-zeroetl-mirroring] FROM EXTERNAL PROVIDER;

SELECT *FROM sys.server_principals WHERE name = 'sp-zeroetl-mirroring';


--> connect to AdventureWorks_Mirror


CREATE USER [sp-zeroetl-mirroring] FOR LOGIN [sp-zeroetl-mirroring];

SELECT * FROM sys.database_principals WHERE name = 'sp-zeroetl-mirroring';


GRANT SELECT TO [sp-zeroetl-mirroring];
GRANT ALTER ANY EXTERNAL MIRROR TO [sp-zeroetl-mirroring];
GRANT VIEW DATABASE PERFORMANCE STATE TO [sp-zeroetl-mirroring];
GRANT VIEW DATABASE SECURITY STATE TO [sp-zeroetl-mirroring];

SELECT * FROM sys.database_permissions WHERE grantee_principal_id = USER_ID('sp-zeroetl-mirroring');









/*
	Alternatywnie możemy utworzyć w bazie danych login i użytkownika z odpowiednimi uprawnieniami
*/


--> connect to master

CREATE LOGIN fabric_mirroring_login WITH PASSWORD = 'Pa$$w0rd123';

SELECT * FROM sys.sql_logins WHERE name = 'fabric_mirroring_login';


--> connect to AdventureWorks_Mirror


CREATE USER fabric_mirroring_user FOR LOGIN fabric_mirroring_login;

SELECT * FROM sys.database_principals WHERE name = 'fabric_mirroring_user';


GRANT SELECT TO fabric_mirroring_user;
GRANT ALTER ANY EXTERNAL MIRROR TO fabric_mirroring_user;
GRANT VIEW DATABASE PERFORMANCE STATE TO fabric_mirroring_user;
GRANT VIEW DATABASE SECURITY STATE TO fabric_mirroring_user;

SELECT * FROM sys.database_permissions WHERE grantee_principal_id = USER_ID('fabric_mirroring_user');



/*
	3. Konfiguracja Mirroring w Fabric
*/




/*
	4. Wymagania i ograniczenia
*/

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ut.name AS UserDataType,
    SCHEMA_NAME(ut.schema_id) AS TypeSchema,
    bt.name AS BaseDataType
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
JOIN sys.columns AS c ON c.object_id = t.object_id
JOIN sys.types AS ut ON ut.user_type_id = c.user_type_id
LEFT JOIN sys.types AS bt
    ON bt.user_type_id = c.system_type_id
    AND bt.is_user_defined = 0
WHERE ut.is_user_defined = 1
ORDER BY s.name, t.name, c.column_id;



/*
	5. Test replikacji
*/


-- Pierwsza zmiana ceny
UPDATE SalesLT.Product SET ListPrice = 1500 WHERE ProductID = 680;

-- Druga zmiana ceny
UPDATE SalesLT.Product SET ListPrice = 1800 WHERE ProductID = 680;


/*
	5. Extended Capabilities
*/


-- UPDATE 3
UPDATE SalesLT.Product SET ListPrice = 2000 WHERE ProductID = 680;


--> test table_changes #1


-- INSERT
INSERT INTO SalesLT.Product
(Name, ProductNumber, StandardCost, ListPrice, SellStartDate)
VALUES ('Zero-ETL Demo Product', 'ZEROETL-001', 100, 250, GETDATE());

SELECT TOP 10 *
FROM SalesLT.Product
ORDER BY 1 DESC


--> test table_changes #2


-- DELETE
DELETE FROM SalesLT.Product
WHERE ProductNumber = 'ZEROETL-001';

-- UPDATE 4
UPDATE SalesLT.Product SET ListPrice = 2500 WHERE ProductID = 680;



--> test table_changes #3










/*
	7. Cleanup
*/


-- Przywrócenie oryginalnej ceny
UPDATE SalesLT.Product
SET ListPrice = 1431.50
WHERE ProductID = 680;

-- Usunięcie produktu demonstracyjnego
DELETE FROM SalesLT.Product
WHERE ProductNumber = 'ZEROETL-001';


-- Weryfikacja
SELECT
    ProductID,
    ProductNumber,
    ListPrice
FROM SalesLT.Product
WHERE ProductID = 680
   OR ProductNumber = 'ZEROETL-001';


DROP USER IF EXISTS [sp-zeroetl-mirroring];
DROP USER IF EXISTS fabric_mirroring_user;
GO

DROP LOGIN IF EXISTS [sp-zeroetl-mirroring];
DROP LOGIN IF EXISTS fabric_mirroring_login;
GO
