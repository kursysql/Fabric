/*
	Copy job
	* Cleanup

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/


USE AdventureWorks2022
GO


DELETE FROM Sales.SalesOrderHeader WHERE SalesOrderID > 75123



UPDATE Production.Product SET Name = 'Bearing Ball' WHERE ProductID = 2

DELETE FROM Production.Product WHERE ProductID > 999

DBCC CHECKIDENT ('Production.Product', RESEED, 999);

--SELECT * FROM Production.Product ORDER BY ProductID DESC


EXEC sys.sp_cdc_disable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@capture_instance = 'Production_Product' -- domyslna nazwa
GO


EXEC sys.sp_cdc_disable_table
	@source_schema = N'Production',
	@source_name   = N'ProductSubcategory',
	@capture_instance = 'Production_ProductSubcategory' -- domyslna nazwa
GO


EXEC sys.sp_cdc_disable_table
	@source_schema = N'Production',
	@source_name   = N'ProductCategory',
	@capture_instance = 'Production_ProductCategory' -- domyslna nazwa
GO


EXEC sys.sp_cdc_disable_db
GO