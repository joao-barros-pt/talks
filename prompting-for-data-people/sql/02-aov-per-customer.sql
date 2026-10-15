/*  02-aov-per-customer.sql
    Reference answers for demo 2 (open questions first, then patch).
    Order value = SubTotal (no tax, no freight) comes from AGENTS.md.
    Answers given to the assistant: all orders in the table, customers with at least one order,
    round only in the output, highest first.
*/

/* Step 1: average order value per customer */
SELECT  c.CustomerID,
        c.CompanyName,
        COUNT(soh.SalesOrderID)                                AS Orders,
        SUM(soh.SubTotal)                                      AS OrderValue,
        CAST(SUM(soh.SubTotal) / COUNT(soh.SalesOrderID) AS decimal(19, 2)) AS AvgOrderValue
FROM SalesLT.Customer AS c
JOIN SalesLT.SalesOrderHeader AS soh
     ON soh.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY AvgOrderValue DESC;

/* Step 2, patch: add rank and share of total, nothing else changes */
WITH per_customer AS (
    SELECT  c.CustomerID,
            c.CompanyName,
            COUNT(soh.SalesOrderID) AS Orders,
            SUM(soh.SubTotal)       AS OrderValue
    FROM SalesLT.Customer AS c
    JOIN SalesLT.SalesOrderHeader AS soh
         ON soh.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CompanyName
)
SELECT  CustomerID,
        CompanyName,
        Orders,
        OrderValue,
        CAST(OrderValue / Orders AS decimal(19, 2))                              AS AvgOrderValue,
        RANK() OVER (ORDER BY OrderValue DESC)                                   AS ValueRank,
        CAST(CAST(OrderValue AS decimal(19, 4)) / SUM(OrderValue) OVER () AS decimal(9, 4)) AS ShareOfTotal
FROM per_customer
ORDER BY AvgOrderValue DESC;

/* Step 3, patch: include customers with no orders as zero */
WITH per_customer AS (
    SELECT  c.CustomerID,
            c.CompanyName,
            COUNT(soh.SalesOrderID)          AS Orders,
            COALESCE(SUM(soh.SubTotal), 0)   AS OrderValue
    FROM SalesLT.Customer AS c
    LEFT JOIN SalesLT.SalesOrderHeader AS soh
         ON soh.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CompanyName
)
SELECT  CustomerID,
        CompanyName,
        Orders,
        OrderValue,
        CAST(OrderValue / NULLIF(Orders, 0) AS decimal(19, 2))                   AS AvgOrderValue,
        RANK() OVER (ORDER BY OrderValue DESC)                                   AS ValueRank,
        CAST(CAST(OrderValue AS decimal(19, 4)) / NULLIF(SUM(OrderValue) OVER (), 0) AS decimal(9, 4)) AS ShareOfTotal
FROM per_customer
ORDER BY AvgOrderValue DESC;

/* Evidence: the per-customer values must add up to the header total */
SELECT SUM(SubTotal) AS TotalOrderValue, COUNT(*) AS Orders
FROM SalesLT.SalesOrderHeader;
