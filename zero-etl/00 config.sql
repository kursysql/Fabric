/*

	Fabric Zero-ETL
	CONFIG
    
    Fabric SQL: sql_zeroetl_control


	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/

IF SCHEMA_ID('etl') IS NULL
    EXEC ('CREATE SCHEMA etl');
GO


DROP TABLE IF EXISTS etl.IngestConfig;


CREATE TABLE etl.IngestConfig
(
    ConfigId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_IngestConfig PRIMARY KEY,
    SourceSchema      NVARCHAR(128) NOT NULL,
    SourceTable       NVARCHAR(128) NOT NULL,
    TargetTable       NVARCHAR(128) NOT NULL,
    KeyColumn         NVARCHAR(128) NOT NULL,
    WatermarkColumn   NVARCHAR(128) NOT NULL,
    LastWatermark     DATETIME2(7) NOT NULL CONSTRAINT DF_IngestConfig_LastWatermark DEFAULT ('1900-01-01'),
    IsEnabled         BIT NOT NULL CONSTRAINT DF_IngestConfig_IsEnabled DEFAULT (1),
    CreatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_IngestConfig_CreatedAt DEFAULT (SYSUTCDATETIME()),
    UpdatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_IngestConfig_UpdatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_IngestConfig_Source UNIQUE (SourceSchema, SourceTable)
);


/*
    Demo configuration - AdventureWorksLT
*/

INSERT INTO etl.IngestConfig (SourceSchema, SourceTable, TargetTable, KeyColumn, WatermarkColumn)
VALUES ('SalesLT', 'Customer', 'customer_pipeline', 'CustomerID', 'ModifiedDate');


INSERT INTO etl.IngestConfig (SourceSchema, SourceTable, TargetTable, KeyColumn, WatermarkColumn)
VALUES ('SalesLT', 'Address', 'address_pipeline', 'AddressID', 'ModifiedDate');

INSERT INTO etl.IngestConfig (SourceSchema, SourceTable, TargetTable, KeyColumn, WatermarkColumn)
VALUES ('SalesLT', 'Product', 'product_pipeline', 'ProductID', 'ModifiedDate');



SELECT * FROM etl.IngestConfig
ORDER BY ConfigId;