/*  00-sanity-checks.sql
    Run once while setting up. Confirms the facts the demos rely on.
    Copy the numbers into the "Data notes" section of the schema card.
*/

/* Orders and their date range */
SELECT  COUNT(*)        AS Orders,
        MIN(OrderDate)  AS FirstOrderDate,
        MAX(OrderDate)  AS LastOrderDate
FROM SalesLT.SalesOrderHeader;

/* Order lines, and lines per order */
SELECT  COUNT(*)                                        AS OrderLines,
        COUNT(DISTINCT SalesOrderID)                    AS OrdersWithLines,
        CAST(COUNT(*) AS decimal(10, 2)) / NULLIF(COUNT(DISTINCT SalesOrderID), 0) AS LinesPerOrder
FROM SalesLT.SalesOrderDetail;

/* Customers with and without orders */
SELECT  COUNT(*)                                                     AS Customers,
        SUM(CASE WHEN o.CustomerID IS NOT NULL THEN 1 ELSE 0 END)    AS CustomersWithOrders
FROM SalesLT.Customer AS c
LEFT JOIN (SELECT DISTINCT CustomerID FROM SalesLT.SalesOrderHeader) AS o
       ON o.CustomerID = c.CustomerID;

/* The NULL trap needs products with no colour: this must be greater than zero */
SELECT  COUNT(*)                                            AS Products,
        SUM(CASE WHEN Color IS NULL THEN 1 ELSE 0 END)      AS ProductsWithNullColor,
        SUM(CASE WHEN Color = N'Red' THEN 1 ELSE 0 END)     AS RedProducts
FROM SalesLT.Product;

/* Category hierarchy: top level vs second level, and products without a category */
SELECT  SUM(CASE WHEN ParentProductCategoryID IS NULL THEN 1 ELSE 0 END)     AS TopLevelCategories,
        SUM(CASE WHEN ParentProductCategoryID IS NOT NULL THEN 1 ELSE 0 END) AS SecondLevelCategories
FROM SalesLT.ProductCategory;

SELECT COUNT(*) AS ProductsWithoutCategory
FROM SalesLT.Product
WHERE ProductCategoryID IS NULL;

/* TotalDue = SubTotal + TaxAmt + Freight, and SubTotal against the sum of the lines.
   In AdventureWorksLT the last two differ (865,433.12 against 708,690.15): a quirk of the sample.
   That is why AGENTS.md defines revenue (lines) and order value (headers) separately. */
SELECT  SUM(h.TotalDue)                              AS TotalDue,
        SUM(h.SubTotal + h.TaxAmt + h.Freight)       AS SubTotalPlusTaxPlusFreight,
        SUM(h.SubTotal)                              AS SubTotal,
        (SELECT SUM(LineTotal) FROM SalesLT.SalesOrderDetail) AS SumOfLineTotal
FROM SalesLT.SalesOrderHeader AS h;
