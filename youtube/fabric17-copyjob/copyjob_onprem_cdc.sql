/*

	Copy job
	Change Data Capture (CDC)
	fragment szkolenia: Szkolenie: SQL zaawansowany

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/




USE AdventureWorks2022
GO



-- wyłączenie dla bazy danych
EXEC sys.sp_cdc_disable_db
GO

-- ponowne włączenie dla bazy danych i sprawdzenie listy tabel systemowych w SSMS
EXEC sys.sp_cdc_enable_db
GO

 


-- włączenie dla tabeli powiedzie się dopiero po uruchomieniu SQL Server Agent
-- !!! SQLServerAgent is not currently running so it cannot be notified of this action.
EXEC sys.sp_cdc_enable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@role_name     = NULL,
	@supports_net_changes = 1 -- tylko ostatnia zmiana
GO



-- domyślna nazwa tabeli: Production_Product
SELECT * FROM cdc.change_tables



-- wyłączenie wymaga podania nazw obu tabel (śledzonej i tej w której są zapisywane zmiany)
EXEC sys.sp_cdc_disable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@capture_instance = 'Production_Product' -- domyslna nazwa
GO



EXEC sys.sp_cdc_enable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@capture_instance = 'Production_Product', -- def: cdc.dbo_People_CT
	--@captured_column_list = 'ProductID, Name, Color', -- sledzone kolumny, musi zawierac PK
	@role_name     = NULL,
	@supports_net_changes = 1 -- ! tylko ostatnia zmiana - musi być włączone pod kątem CopyJob w Fabric
GO


-- włączenie 2 innych tabel
EXEC sys.sp_cdc_enable_table
	@source_schema = N'Production',
	@source_name   = N'ProductSubcategory',
	@role_name     = NULL,
	@supports_net_changes = 1 -- tylko ostatnia zmiana
GO

EXEC sys.sp_cdc_enable_table
	@source_schema = N'Production',
	@source_name   = N'ProductCategory',
	@role_name     = NULL,
	@supports_net_changes = 1 -- tylko ostatnia zmiana
GO






-- lista śledzonych tabel
SELECT * FROM cdc.change_tables

-- zawartość tabeli zmian
SELECT * FROM cdc.Production_Product_CT


------------------------
--> Fabric CopyJob3_cdc
------------------------

-- zmiana jednego z wierszy

SELECT * FROM Production.Product WHERE ProductID <10


-- MODYFIKACJA wiersza
-- Name: Bearing Ball
UPDATE Production.Product SET Name = 'Bearing Ball EDITED' WHERE ProductID = 2

SELECT * FROM Production.Product WHERE ProductID <10

-- operation: 3 (przed zmianą), 4 (po zmianie)
SELECT * FROM cdc.Production_Product_CT




-- __$update_mask - pozwala sprawdzić które kolumny zostały zmienione
SELECT 
	sys.fn_cdc_has_column_changed ('Production_Product', 'ProductID', __$update_mask) AS ProductID_Changed,
	sys.fn_cdc_has_column_changed ('Production_Product', 'Name', __$update_mask) AS Name_Changed,
	sys.fn_cdc_has_column_changed ('Production_Product', 'ProductNumber', __$update_mask) AS ProductNumber_Changed,
	*
FROM cdc.Production_Product_CT




-- WSTAWIENIE wiersza
INSERT INTO Production.Product
(    Name,    ProductNumber,    MakeFlag,    FinishedGoodsFlag,    SafetyStockLevel,    ReorderPoint,    StandardCost,    ListPrice,
    DaysToManufacture,    SellStartDate,    rowguid,    ModifiedDate)
VALUES
(    'Road Frame Carbon 58',    'RF-C58',    1,    1,    1000,    750,    500.00,    999.99,
    5,    GETDATE(),    NEWID(),    GETDATE());



-- wstawienie 3 wierszy w ramach tej samej transakcji

INSERT INTO Production.Product
(    Name,    ProductNumber,    MakeFlag,    FinishedGoodsFlag,    SafetyStockLevel,    ReorderPoint,    StandardCost,    ListPrice,    DaysToManufacture,
    SellStartDate,    rowguid,    ModifiedDate)
VALUES
(    'Road Frame Carbon 48',    'RF-C59',    1,    1,    1000,    750,    500.00,    999.99,    5,
    GETDATE(),    NEWID(),    GETDATE()),
(    'Mountain Tire 29x2.1',    'MT-29X21',    1,    1,    500,    300,    20.00,    49.99,    2,
    GETDATE(),    NEWID(),    GETDATE()),
(    'Cycling Helmet Pro',    'CH-PRO',    1,    1,    250,    150,    15.00,    39.99,    1,
    GETDATE(),    NEWID(),    GETDATE());


-- ten sam start_lsn dla 3 nowych wierszy
SELECT * FROM cdc.Production_Product_CT


-- __$update_mask - pozwala sprawdzić które kolumny zostały zmienione
SELECT 
	sys.fn_cdc_has_column_changed ('Production_Product', 'ProductID', __$update_mask) AS ProductID_Changed,
	sys.fn_cdc_has_column_changed ('Production_Product', 'Name', __$update_mask) AS Name_Changed,
	sys.fn_cdc_has_column_changed ('Production_Product', 'ProductNumber', __$update_mask) AS ProductNumber_Changed,
	*
FROM cdc.Production_Product_CT







-- operation: 2 wstawienie
SELECT * FROM cdc.Production_Product_CT



------------------------
--> Fabric CopyJob3_cdc
------------------------




-- SKASOWANIE wiersza
DELETE FROM Production.Product WHERE ProductID = 1003


-- operation: 1 skasowanie
SELECT * FROM cdc.Production_Product_CT





------------------------
--> Fabric CopyJob3_cdc
------------------------


-- wyłączenie i włączenie cdc na tabeli
EXEC sys.sp_cdc_disable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@capture_instance = 'Production_Product' 
GO



EXEC sys.sp_cdc_enable_table
	@source_schema = N'Production',
	@source_name   = N'Product',
	@capture_instance = 'Production_Product',
	@role_name     = NULL,
	@supports_net_changes = 1 
GO








------------------------
--> Fabric CopyJob3_cdc - wymaganiua 
------------------------





