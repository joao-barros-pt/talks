/*  00-row-counts-by-company.sql
    Run once after every Dataflow Gen2 load, on the SQL analytics endpoint of the lakehouse bc_lab
    (VS Code, MSSQL extension). Read-only: nothing here changes data.
    Write the numbers down in the README table: they are the ones the demos must show.
*/

/* 1. Rows per table and company. Four companies in every table, none with zero rows. */
SELECT  t.tableName,
        t.company,
        t.rowsLoaded
FROM (
        SELECT N'customers'            AS tableName, company, COUNT_BIG(*) AS rowsLoaded FROM dbo.customers            GROUP BY company
        UNION ALL
        SELECT N'items',                             company, COUNT_BIG(*)               FROM dbo.items                GROUP BY company
        UNION ALL
        SELECT N'salesInvoices',                     company, COUNT_BIG(*)               FROM dbo.salesInvoices        GROUP BY company
        UNION ALL
        SELECT N'generalLedgerEntries',              company, COUNT_BIG(*)               FROM dbo.generalLedgerEntries GROUP BY company
     ) AS t
ORDER BY t.tableName, t.company;

/* 2. Invoice status per company. AGENTS.md counts Open and Paid as posted.
      Check the exact spelling of each value here (an enum with a space may come encoded). */
SELECT  company,
        status,
        COUNT_BIG(*)                 AS invoices,
        SUM(totalAmountExcludingTax) AS amountExcludingTax
FROM dbo.salesInvoices
GROUP BY company, status
ORDER BY company, status;

/* 3. Currency of the invoices. Expected: EUR in CRONUS Lisboa, CRONUS Porto and CRONUS Madrid, GBP in CRONUS London.
      Revenue adds up within one currency, never across the four companies without a conversion.
      For invoices in local currency the API should return the local currency code; if it comes empty here,
      the LCY Code in General Ledger Setup of each company says which currency it is. To be confirmed in the lab. */
SELECT  company,
        COALESCE(NULLIF(currencyCode, N''), N'(local)') AS currency,
        COUNT_BIG(*)                                    AS invoices
FROM dbo.salesInvoices
GROUP BY company, COALESCE(NULLIF(currencyCode, N''), N'(local)')
ORDER BY company, currency;

/* 4. Tax: excluding tax plus tax equals including tax. Must return 0 rows with a difference. */
SELECT  COUNT_BIG(*) AS invoicesWithTaxDifference
FROM dbo.salesInvoices
WHERE ABS(totalAmountExcludingTax + totalTaxAmount - totalAmountIncludingTax) > 0.01;

/* 5. The premise of the trap: customer 10000 exists in every company. Expected: 4. */
SELECT  COUNT(DISTINCT company) AS companiesWithCustomer10000
FROM dbo.customers
WHERE number = N'10000';

/* 6. How many customer numbers repeat across companies. With four copies of CRONUS, all of them. */
SELECT  companiesPerNumber,
        COUNT_BIG(*) AS customerNumbers
FROM (
        SELECT number, COUNT(DISTINCT company) AS companiesPerNumber
        FROM dbo.customers
        GROUP BY number
     ) AS n
GROUP BY companiesPerNumber
ORDER BY companiesPerNumber;

/* 7. Keys of the model: the one side of each relationship must be unique. All three must return 0. */
SELECT  N'customers (company, number)' AS keyChecked, COUNT_BIG(*) AS duplicateKeys
FROM (SELECT company, number FROM dbo.customers GROUP BY company, number HAVING COUNT_BIG(*) > 1) AS d
UNION ALL
SELECT  N'customers.customerKey', COUNT_BIG(*)
FROM (SELECT customerKey FROM dbo.customers GROUP BY customerKey HAVING COUNT_BIG(*) > 1) AS d
UNION ALL
SELECT  N'salesInvoices.invoiceKey', COUNT_BIG(*)
FROM (SELECT invoiceKey FROM dbo.salesInvoices GROUP BY invoiceKey HAVING COUNT_BIG(*) > 1) AS d;

/* 8. Document types in the G/L. For information: the cost definition doesn't filter on documentType,
      it matches the G/L entries to posted sales invoices on company and documentNumber (see check 9). */
SELECT  company,
        documentType,
        COUNT_BIG(*) AS entries
FROM dbo.generalLedgerEntries
GROUP BY company, documentType
ORDER BY company, documentType;

/* 9. Accounts posted with the number of a posted sales invoice, in one company, with their document type.
      Use it with the General Posting Setup in Business Central (COGS Account) to find the cost of goods
      sold accounts, then write them in model/snippets/00-starting-measures.tmdl and in
      sql/02-company-key-trap.sql (checks 5 and 6).
      To be confirmed in the lab: that the COGS entries carry the invoice number. If no COGS account shows up,
      look at Inventory Setup, Automatic Cost Posting, in the sandbox. */
SELECT  g.accountNumber,
        g.documentType,
        COUNT_BIG(*)        AS entries,
        SUM(g.debitAmount)  AS debit,
        SUM(g.creditAmount) AS credit
FROM dbo.generalLedgerEntries AS g
WHERE g.company = N'CRONUS Lisboa'
  AND EXISTS (
        SELECT 1
        FROM dbo.salesInvoices AS i
        WHERE i.company = g.company
          AND i.number  = g.documentNumber
          AND i.status IN (N'Open', N'Paid')
      )
GROUP BY g.accountNumber, g.documentType
ORDER BY g.accountNumber, g.documentType;

/* 10. Column list, for the schema file of the cold window in demo 5 (prompts/05-same-task-two-assistants.md). */
SELECT  TABLE_NAME  AS tableName,
        COLUMN_NAME AS columnName,
        DATA_TYPE   AS dataType
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'dbo'
  AND TABLE_NAME IN (N'customers', N'items', N'salesInvoices', N'generalLedgerEntries')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
