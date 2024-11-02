/*
	Fabric
	Mirroring Azure SQL Database

	www.youtube.com/kursysql
	www.kursyfabric.pl

	Tomasz Lbera | MVP Data Platform | 	libera@kursysql.pl
*/



/*
	Testowanie
*/

-- @Fabric

SELECT * FROM dbo.dbo_DimProduct

-- -- Tabele są tylko do odczytu
DELETE FROM dbo.dbo_DimProduct


-- @bazaSQL

-- -- Wykonajmy jakąś modyfikację w tabeli źródłowej
SELECT * FROM DimProduct
UPDATE dbo.DimProduct SET EnglishProductName = 'modified' WHERE ProductKey = 1


-- @Fabric
SELECT * FROM dbo.dbo_DimProduct ORDER BY ProductKey




-- @bazaSQL

TRUNCATE TABLE dbo.DatabaseLog

SELECT * FROM dbo.DimProductCategory
ALTER TABLE dbo.DimProductCategory ADD PolishProductCategoryName varchar(8000)
SELECT * FROM dbo.DimProductCategory

SELECT * FROM dbo.DimProductSubcategory
ALTER TABLE dbo.DimProductSubcategory DROP COLUMN FrenchProductSubcategoryName
SELECT * FROM dbo.DimProductSubcategory

CREATE TABLE testNowejTabeli (id int primary key identity, col2 int)


-- @Fabric

SELECT * FROM dbo_DimProductCategory
SELECT * FROM dbo_DimProductSubcategory
SELECT * FROM dbo_testNowejTabeli



-- @bazaSQL
EXEC sp_rename 'testNowejTabeli', 'nowa_nazwa'


-- @Fabric
SELECT * FROM dbo_nowa_nazwa

