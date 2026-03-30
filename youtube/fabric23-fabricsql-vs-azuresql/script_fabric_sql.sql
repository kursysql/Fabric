/*
	Fabric SQL Database VS Azure SQL Database
	* Fabric Script

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/



----------------------
--
-- backups
--
----------------------

SELECT *
FROM sys.dm_database_backups
--WHERE in_retention = 1
ORDER BY backup_finish_date DESC;


----------------------
--
-- audit
--
-- https://fabric.microsoft.com/groups/<fabric workspace id>/sqldatabases/<fabric sql database id>
----------------------

SELECT * FROM sys.fn_get_audit_file_v2(
  'https://onelake.blob.fabric.microsoft.com/3bfe9854-dc63-4cd5-a4c8-0db94c3bb3eb/8d736beb-3532-477a-9f97-1c85456075b2/Audit/sqldbauditlogs/',
  DEFAULT, DEFAULT, DEFAULT, DEFAULT )



SELECT * FROM SalesLT.Product


SELECT session_id, database_principal_name, database_name, statement, application_name, host_name   
FROM sys.fn_get_audit_file_v2(
  'https://onelake.blob.fabric.microsoft.com/3bfe9854-dc63-4cd5-a4c8-0db94c3bb3eb/8d736beb-3532-477a-9f97-1c85456075b2/Audit/sqldbauditlogs/',
  DEFAULT, DEFAULT, DEFAULT, DEFAULT )
WHERE statement LIKE '%SalesLT.Product%' AND application_name = 'Microsoft SQL Server Management Studio - Query'




----------------------
--
-- compatibility_level
--
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver17
----------------------


--| compatibility_level | Wersja SQL Server                         |
--| ------------------: | ----------------------------------------- |
--|                 170 | SQL Server 2025 (17.x)                    |
--|                 160 | SQL Server 2022 (16.x)                    |
--|                 150 | SQL Server 2019 (15.x)                    |
--|                 140 | SQL Server 2017 (14.x)                    |
--|                 130 | SQL Server 2016 (13.x)                    |
--|                 120 | SQL Server 2014 (12.x)                    |
--|                 110 | SQL Server 2012 (11.x)                    |
--|                 100 | SQL Server 2008 / 2008 R2 (10.x / 10.5.x) |
--|                  90 | SQL Server 2005 (9.x)                     |
--|                  80 | SQL Server 2000 (8.x)                     |



-- compat_lvl - domyślnie 170
SELECT name, compatibility_level FROM sys.databases

ALTER DATABASE [SampleSQLFabric-8d736beb-3532-477a-9f97-1c85456075b2]
SET COMPATIBILITY_LEVEL = 140


-- !
ALTER DATABASE [SampleSQLFabric-8d736beb-3532-477a-9f97-1c85456075b2]
SET COMPATIBILITY_LEVEL = 80

--Msg 15048, Level 16, State 1, Line 10
--Valid values of the database compatibility level are 100, 110, 120, 130, 140, 150, 160 or 170.
 


SELECT name, compatibility_level FROM sys.databases


-- powrót do domyślnych ustawień
ALTER DATABASE [SampleSQLFabric-8d736beb-3532-477a-9f97-1c85456075b2]
SET COMPATIBILITY_LEVEL = 170




----------------------
-- collation
----------------------

SELECT name, collation_name FROM sys.databases

-- notatnik - utworzenie bazy z innym niż std collaction (nie oznacza zmiany SQL endpoint collation)
-- https://github.com/microsoft/fabric-toolbox/blob/main/samples/notebook-create-sql-database/CreateSQLDB.ipynb

