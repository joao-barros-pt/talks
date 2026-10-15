/*  01-revenue-by-top-category.sql
    Reference answer for demo 1 (bad prompt vs good prompt).
    Revenue = SUM(SalesOrderDetail.LineTotal). Top-level category = the parent of the product's category.
*/

WITH category AS (
    SELECT  pc.ProductCategoryID,
            COALESCE(parent.Name, pc.Name) AS TopCategory
    FROM SalesLT.ProductCategory AS pc
    LEFT JOIN SalesLT.ProductCategory AS parent
           ON parent.ProductCategoryID = pc.ParentProductCategoryID
)
SELECT  COALESCE(category.TopCategory, N'(no category)') AS TopCategory,
        SUM(sod.LineTotal)                               AS Revenue,
        COUNT(DISTINCT sod.SalesOrderID)                 AS Orders
FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.Product AS p
     ON p.ProductID = sod.ProductID
LEFT JOIN category
     ON category.ProductCategoryID = p.ProductCategoryID
GROUP BY COALESCE(category.TopCategory, N'(no category)')
ORDER BY Revenue DESC;

/* Evidence: the categories above must add up to this */
SELECT SUM(LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail;
