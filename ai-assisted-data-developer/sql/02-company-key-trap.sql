/*  02-company-key-trap.sql
    Demo 5: the evidence. A join that reads well, runs, and multiplies.
    SQL analytics endpoint of the lakehouse bc_lab.

    Customer numbers repeat across companies: customer 10000 exists in all four.
    Joining invoices to customers on the number alone matches every invoice to the same customer
    in every company. With four copies of the same customers, the total comes out exactly four times too big.
    The key is company + number.
    The revenue totals below mix EUR (Lisboa, Porto, Madrid) and GBP (London): they compare the joins, they are not revenue.
*/

/* 1. WRONG: join on the number only. It runs without an error. */
SELECT  i.company,
        c.number                       AS customerNumber,
        c.displayName                  AS customerName,
        SUM(i.totalAmountExcludingTax) AS revenue
FROM dbo.salesInvoices AS i
JOIN dbo.customers     AS c
  ON c.number = i.customerNumber                  -- the company is missing
WHERE i.status IN (N'Open', N'Paid')
GROUP BY i.company, c.number, c.displayName
ORDER BY revenue DESC;

/* 2. RIGHT: join on company and number. */
SELECT  i.company,
        c.number                       AS customerNumber,
        c.displayName                  AS customerName,
        SUM(i.totalAmountExcludingTax) AS revenue
FROM dbo.salesInvoices AS i
JOIN dbo.customers     AS c
  ON c.company = i.company
 AND c.number  = i.customerNumber
WHERE i.status IN (N'Open', N'Paid')
GROUP BY i.company, c.number, c.displayName
ORDER BY revenue DESC;

/* 3. Reconciliation: rows and totals before and after each join, against the source.
      Right join: same rows and same total as the source.
      Wrong join: exactly four times both, because every customer number exists in all four companies
      (check 6 of sql/00-row-counts-by-company.sql). wrongOverRight must read 4.00. */
WITH src AS (
        SELECT COUNT_BIG(*) AS invoiceRows, SUM(totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
),
wrongJoin AS (
        SELECT COUNT_BIG(*) AS invoiceRows, SUM(i.totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices AS i
        JOIN dbo.customers AS c ON c.number = i.customerNumber
        WHERE i.status IN (N'Open', N'Paid')
),
rightJoin AS (
        SELECT COUNT_BIG(*) AS invoiceRows, SUM(i.totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices AS i
        JOIN dbo.customers AS c ON c.company = i.company AND c.number = i.customerNumber
        WHERE i.status IN (N'Open', N'Paid')
)
SELECT  s.invoiceRows                                      AS sourceRows,
        r.invoiceRows                                      AS rightJoinRows,
        w.invoiceRows                                      AS wrongJoinRows,
        s.revenue                                          AS sourceRevenue,
        r.revenue                                          AS rightJoinRevenue,
        w.revenue                                          AS wrongJoinRevenue,
        CAST(w.revenue / NULLIF(r.revenue, 0) AS decimal(9, 2)) AS wrongOverRight
FROM src AS s CROSS JOIN rightJoin AS r CROSS JOIN wrongJoin AS w;

/* 4. The same check per company: every company must reconcile on its own before the companies are combined. */
WITH src AS (
        SELECT company, SUM(totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
        GROUP BY company
),
joined AS (
        SELECT i.company, SUM(i.totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices AS i
        JOIN dbo.customers AS c ON c.company = i.company AND c.number = i.customerNumber
        WHERE i.status IN (N'Open', N'Paid')
        GROUP BY i.company
)
SELECT  s.company,
        s.revenue                         AS sourceRevenue,
        j.revenue                         AS joinedRevenue,
        COALESCE(j.revenue, 0) - s.revenue AS revenueDifference   -- must be 0 in every company
FROM src AS s
LEFT JOIN joined AS j ON j.company = s.company
ORDER BY s.company;

/* 5. The right answer to the demo 5 prompt: customer margin across all companies.
      Cost comes from the G/L entries on the cost of goods sold accounts, matched to the posted invoice on
      company + documentNumber. The same trap exists here: documentNumber repeats across companies.
      FILL IN the accounts from check 9 of sql/00-row-counts-by-company.sql before running.
      With the placeholder left in, cost is 0 and margin equals revenue.
      Revenue and cost stay in the currency of each company: the margin % compares across companies, the amounts don't. */
WITH cogsAccounts AS (
        SELECT accountNumber
        FROM (VALUES (N'<cogs-account>')) AS a (accountNumber)
),
costPerInvoice AS (                                -- aggregate first, so the join can't fan out
        SELECT g.company,
               g.documentNumber,
               SUM(g.debitAmount - g.creditAmount) AS cost
        FROM dbo.generalLedgerEntries AS g
        JOIN cogsAccounts AS a ON a.accountNumber = g.accountNumber
        GROUP BY g.company, g.documentNumber
),
invoices AS (
        SELECT i.company,
               i.customerNumber,
               i.totalAmountExcludingTax  AS revenue,
               COALESCE(k.cost, 0)        AS cost
        FROM dbo.salesInvoices AS i
        LEFT JOIN costPerInvoice AS k
               ON k.company        = i.company
              AND k.documentNumber = i.number
        WHERE i.status IN (N'Open', N'Paid')
)
SELECT  v.company,
        v.customerNumber,
        c.displayName                                        AS customerName,
        SUM(v.revenue)                                       AS revenue,
        SUM(v.cost)                                          AS cost,
        SUM(v.revenue) - SUM(v.cost)                         AS grossMargin,
        (SUM(v.revenue) - SUM(v.cost)) / NULLIF(SUM(v.revenue), 0) AS grossMarginPct
FROM invoices AS v
LEFT JOIN dbo.customers AS c
       ON c.company = v.company
      AND c.number  = v.customerNumber
GROUP BY v.company, v.customerNumber, c.displayName
ORDER BY v.company, revenue DESC;

/* 6. Reconciliation of 5: after the cost join, revenue still equals the source and the rows are still one per invoice.
      Both differences must be 0. Fill the same accounts as in 5. */
WITH cogsAccounts AS (
        SELECT accountNumber
        FROM (VALUES (N'<cogs-account>')) AS a (accountNumber)
),
costPerInvoice AS (
        SELECT g.company, g.documentNumber, SUM(g.debitAmount - g.creditAmount) AS cost
        FROM dbo.generalLedgerEntries AS g
        JOIN cogsAccounts AS a ON a.accountNumber = g.accountNumber
        GROUP BY g.company, g.documentNumber
),
joined AS (
        SELECT COUNT_BIG(*) AS invoiceRows, SUM(i.totalAmountExcludingTax) AS revenue, SUM(COALESCE(k.cost, 0)) AS cost
        FROM dbo.salesInvoices AS i
        LEFT JOIN costPerInvoice AS k ON k.company = i.company AND k.documentNumber = i.number
        WHERE i.status IN (N'Open', N'Paid')
),
src AS (
        SELECT COUNT_BIG(*) AS invoiceRows, SUM(totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
)
SELECT  j.invoiceRows - s.invoiceRows AS rowDifference,
        j.revenue - s.revenue         AS revenueDifference,
        j.cost                        AS totalCost
FROM joined AS j CROSS JOIN src AS s;
