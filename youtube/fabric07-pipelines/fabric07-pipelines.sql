/*
	Fabric
	Pipelines

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/


USE AdventureWorks2022

SELECT * FROM Production.Product

SELECT * FROM Production.ProductCategory

SELECT * FROM Production.ProductDescription


/*
	Lookup
	Zmiana parametru na tabelę 
*/
DROP TABLE IF EXISTS dbo.ETLHistory
GO

CREATE TABLE dbo.ETLHistory (
TableID int identity PRIMARY KEY,
SchemaName sysname NOT NULL,
TableName sysname NOT NULL)
GO

INSERT INTO dbo.ETLHistory (SchemaName, TableName) VALUES 
	('Production', 'Product'), ('Production', 'ProductCategory'), ('Production', 'ProductDescription')

-- Lookup Activity
SELECT TableID, SchemaName, TableName FROM dbo.ETLHistory




/*
	AdventureWorksLH
*/

SELECT * FROM Production_ProductCategory




/*
	Script
	Czas pobrania tabeli
*/

ALTER TABLE ETLHistory ADD LastIngestTime datetime2 NULL

UPDATE ETLHistory SET LastIngestTime = GETDATE() WHERE SchemaName = 'Production' AND TableName = 'Product'

SELECT * FROM dbo.ETLHistory

-- LastIngestTime
/*
@concat('UPDATE ETLHistory SET LastIngestTime = GETDATE() WHERE SchemaName = ''',item().SchemaName,''' AND TableName = ''',item().TableName,''' AND 1=1')
*/

SELECT * FROM dbo.ETLHistory



/*
	Teams/ email
	Powiadamianie o sukcesie/ błędzie

*/


INSERT INTO dbo.ETLHistory (SchemaName, TableName) VALUES 
	('Production', 'Product123')

SELECT * FROM dbo.ETLHistory

DELETE FROM ETLHistory WHERE TableName = 'Product123'






