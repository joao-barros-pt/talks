# Project context

Demo repository for "Prompting for Data People". AI assistants read this file at the start of every session. Keep it short and factual.

## Data sources

- T-SQL: AdventureWorksLT sample, schema `SalesLT`, on SQL database in Fabric, Azure SQL Database or SQL Server.
- DAX: Adventure Works DW 2020 sample model, saved as a Power BI Project. The model definition (TMDL) is under `*.SemanticModel/definition/`.
- Python: CSV exports of `SalesLT.SalesOrderHeader` and `SalesLT.SalesOrderDetail` in `python/data/`.
- Schema card with columns, keys and sample rows: `context/schema-card-adventureworkslt.md`.

## Grain: read before writing any aggregation

- `SalesLT.SalesOrderHeader`: one row per sales order. Money columns: `SubTotal`, `TaxAmt`, `Freight`, `TotalDue` (`TotalDue` = `SubTotal` + `TaxAmt` + `Freight`).
- `SalesLT.SalesOrderDetail`: one row per order line. `LineTotal` is the line amount after discount, without tax or freight.
- `SalesLT.ProductCategory`: two-level hierarchy through `ParentProductCategoryID`. Top-level categories have `ParentProductCategoryID IS NULL`.
- DAX model, table `Sales`: one row per sales order line. `'Sales Order'[Sales Order]` is the order number.

## Business definitions

- Revenue, product view: `SUM(SalesLT.SalesOrderDetail.LineTotal)`.
- Order value, customer view: `SalesLT.SalesOrderHeader.SubTotal`. Use `TotalDue` only when the request says "including tax and freight".
- Average order value: total order value divided by the number of distinct orders. Never an average of line amounts.

## Conventions

- T-SQL: schema-qualified names, explicit column lists (no `SELECT *`), ANSI joins, handle NULLs explicitly.
- Never send or print personal data columns (`EmailAddress`, `Phone`, `PasswordHash`, `PasswordSalt`).
- State assumptions at the top of the answer.
- With every aggregate, also give a reconciliation check against the source table.
- If grain, a business definition, a filter or the period is ambiguous, ask up to three questions before writing code.
