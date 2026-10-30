# Copilot instructions

Keep in sync with `AGENTS.md` in this folder.

- Data: Business Central CRONUS demo data, four companies, landed in the Fabric lakehouse `bc_lab`, schema `dbo`: `customers`, `items`, `salesInvoices` (invoice headers), `generalLedgerEntries`.
- Every table has a `company` column. The company is part of every key: join on `company` and the number, never on the number alone. Customer `10000` exists in all four companies.
- Model keys: `customerKey` and `invoiceKey` (`company|number`), built in Power Query.
- Posted invoice: `status` is `Open` or `Paid`. Revenue = `SUM(totalAmountExcludingTax)` over posted invoices. Cost = G/L entries on the cost of goods sold accounts, matched to posted invoices on `company` and `documentNumber`. Gross margin % = `DIVIDE(revenue - cost, revenue)`. Amounts stay in the currency of each company (EUR in Lisboa, Porto and Madrid, GBP in London): never add up different currencies.
- T-SQL: schema-qualified names, explicit column lists, ANSI joins, NULLs handled explicitly. The SQL endpoint is read-only.
- DAX and TMDL: `DIVIDE` for ratios, a `///` description on every new measure and function, tabs for indentation.
- Never output contact columns (`email`, `phoneNumber`, addresses), secrets, tenant IDs or connection strings.
- State assumptions first. With every aggregate, add a reconciliation per company against the source table.
- If grain, a definition, a filter or the period is ambiguous, ask up to three questions before writing code.
