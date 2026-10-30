/*  01-demo1-revenue-by-company.sql
    Demo 1: reference answer for prompts/01-tsql-agent-mode.md.
    SQL analytics endpoint of the lakehouse bc_lab, VS Code with the MSSQL extension.

    Assumptions (the same ones the prompt states):
    - Revenue = SUM(totalAmountExcludingTax), without tax.
    - Only posted invoices: status Open or Paid. Drafts and invoices in review are not revenue.
    - Date = postingDate.
    - Revenue stays in the currency of each company: EUR in Lisboa, Porto and Madrid, GBP in London
      (check 3 in sql/00-row-counts-by-company.sql). A total across the four companies mixes currencies.
*/

/* 1. Revenue per company, in the currency of each company. */
SELECT  company,
        COALESCE(NULLIF(currencyCode, N''), N'(local)') AS currency,
        COUNT_BIG(*)                                    AS postedInvoices,
        SUM(totalAmountExcludingTax)                    AS revenue
FROM dbo.salesInvoices
WHERE status IN (N'Open', N'Paid')
GROUP BY company, COALESCE(NULLIF(currencyCode, N''), N'(local)')
ORDER BY company, currency;

/* 2. Revenue per company and month of posting. */
SELECT  company,
        DATEFROMPARTS(YEAR(postingDate), MONTH(postingDate), 1) AS postingMonth,
        COUNT_BIG(*)                                           AS postedInvoices,
        SUM(totalAmountExcludingTax)                           AS revenue
FROM dbo.salesInvoices
WHERE status IN (N'Open', N'Paid')
GROUP BY company, DATEFROMPARTS(YEAR(postingDate), MONTH(postingDate), 1)
ORDER BY company, postingMonth;

/* 3. Reconciliation, written before reading the result:
      the four companies add up to the source total, and the months add up to the companies.
      Both differences must be 0. The totals mix EUR and GBP: they prove that nothing is lost or counted twice,
      they are not revenue. */
WITH perCompany AS (
        SELECT company, SUM(totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
        GROUP BY company
),
perMonth AS (
        SELECT company, DATEFROMPARTS(YEAR(postingDate), MONTH(postingDate), 1) AS postingMonth,
               SUM(totalAmountExcludingTax) AS revenue
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
        GROUP BY company, DATEFROMPARTS(YEAR(postingDate), MONTH(postingDate), 1)
),
src AS (
        SELECT SUM(totalAmountExcludingTax) AS revenue, COUNT(DISTINCT company) AS companies
        FROM dbo.salesInvoices
        WHERE status IN (N'Open', N'Paid')
)
SELECT  (SELECT companies FROM src)                                   AS companies,
        (SELECT SUM(revenue) FROM perCompany)                            AS sumOfCompanies,
        (SELECT SUM(revenue) FROM perMonth)                              AS sumOfMonths,
        (SELECT revenue FROM src)                                     AS sourceTotal,
        (SELECT SUM(revenue) FROM perCompany) - (SELECT revenue FROM src) AS companiesMinusSource,
        (SELECT SUM(revenue) FROM perMonth) - (SELECT SUM(revenue) FROM perCompany) AS monthsMinusCompanies;

/* 4. What the filter on status leaves out. Not revenue, but worth a look before anyone asks. */
SELECT  company,
        status,
        COUNT_BIG(*)                 AS invoices,
        SUM(totalAmountExcludingTax) AS amountExcludingTax
FROM dbo.salesInvoices
WHERE status IS NULL OR status NOT IN (N'Open', N'Paid')
GROUP BY company, status
ORDER BY company, status;
