/*  build-schema-card.sql
    Builds the pieces of a compact "schema card" for the AdventureWorksLT tables used in the demos:
    columns, relationships, row counts and three sample rows per table, with personal data left out.
    Run as one batch in VS Code (MSSQL extension) against the database with the SalesLT schema.
    Paste the results into context/schema-card-adventureworkslt.md.
*/

DECLARE @tables TABLE (TableName sysname PRIMARY KEY);
INSERT INTO @tables (TableName)
VALUES (N'Customer'), (N'SalesOrderHeader'), (N'SalesOrderDetail'), (N'Product'), (N'ProductCategory');

DECLARE @excluded TABLE (ColumnName sysname PRIMARY KEY);
INSERT INTO @excluded (ColumnName)
VALUES (N'rowguid'), (N'ModifiedDate'), (N'EmailAddress'), (N'Phone'),
       (N'PasswordHash'), (N'PasswordSalt'), (N'ThumbNailPhoto'), (N'ThumbnailPhotoFileName');

/* 1. Columns: one line per table */
SELECT  c.TABLE_SCHEMA + N'.' + c.TABLE_NAME AS [table],
        STRING_AGG(CONVERT(nvarchar(max),
                c.COLUMN_NAME + N' ' + c.DATA_TYPE
                + CASE WHEN c.IS_NULLABLE = 'YES' THEN N' NULL' ELSE N'' END), N', ')
            WITHIN GROUP (ORDER BY c.ORDINAL_POSITION) AS [columns]
FROM INFORMATION_SCHEMA.COLUMNS AS c
JOIN @tables AS t ON t.TableName = c.TABLE_NAME
WHERE c.TABLE_SCHEMA = N'SalesLT'
  AND c.COLUMN_NAME NOT IN (SELECT ColumnName FROM @excluded)
GROUP BY c.TABLE_SCHEMA, c.TABLE_NAME
ORDER BY [table];

/* 2. Relationships between those tables */
SELECT  OBJECT_SCHEMA_NAME(fk.parent_object_id) + N'.' + OBJECT_NAME(fk.parent_object_id) + N'.' + pc.name
        + N' -> '
        + OBJECT_SCHEMA_NAME(fk.referenced_object_id) + N'.' + OBJECT_NAME(fk.referenced_object_id) + N'.' + rc.name
        AS [relationship]
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
JOIN sys.columns AS pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
JOIN sys.columns AS rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = N'SalesLT'
  AND OBJECT_NAME(fk.parent_object_id) IN (SELECT TableName FROM @tables)
  AND OBJECT_NAME(fk.referenced_object_id) IN (SELECT TableName FROM @tables)
ORDER BY [relationship];

/* 3. Row counts */
SELECT N'SalesLT.Customer' AS [table], COUNT_BIG(*) AS [rows] FROM SalesLT.Customer
UNION ALL SELECT N'SalesLT.SalesOrderHeader', COUNT_BIG(*) FROM SalesLT.SalesOrderHeader
UNION ALL SELECT N'SalesLT.SalesOrderDetail', COUNT_BIG(*) FROM SalesLT.SalesOrderDetail
UNION ALL SELECT N'SalesLT.Product', COUNT_BIG(*) FROM SalesLT.Product
UNION ALL SELECT N'SalesLT.ProductCategory', COUNT_BIG(*) FROM SalesLT.ProductCategory;

/* 4. Three sample rows per table, personal data left out. JSON keeps it compact for a prompt. */
SELECT TOP (3) SalesOrderID, OrderDate, CustomerID, SubTotal, TaxAmt, Freight, TotalDue
FROM SalesLT.SalesOrderHeader
ORDER BY SalesOrderID
FOR JSON PATH;

SELECT TOP (3) SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal
FROM SalesLT.SalesOrderDetail
ORDER BY SalesOrderID, SalesOrderDetailID
FOR JSON PATH;

SELECT TOP (3) ProductID, Name, Color, ListPrice, ProductCategoryID
FROM SalesLT.Product
ORDER BY ProductID
FOR JSON PATH;

SELECT TOP (3) ProductCategoryID, ParentProductCategoryID, Name
FROM SalesLT.ProductCategory
ORDER BY ProductCategoryID
FOR JSON PATH, INCLUDE_NULL_VALUES;
