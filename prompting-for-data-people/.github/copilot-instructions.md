# Copilot instructions

Keep in sync with `AGENTS.md` in this folder.

- T-SQL targets the AdventureWorksLT sample, schema `SalesLT`. Use schema-qualified names, explicit column lists and ANSI joins.
- Grain: `SalesOrderHeader` is one row per order, `SalesOrderDetail` is one row per order line. `TotalDue` = `SubTotal` + `TaxAmt` + `Freight`.
- Revenue (product view) = `SUM(SalesOrderDetail.LineTotal)`. Average order value = total order value / number of distinct orders.
- DAX: table `Sales` is one row per order line; `'Sales Order'[Sales Order]` is the order number.
- Handle NULLs explicitly. Never output personal data columns (`EmailAddress`, `Phone`, `PasswordHash`, `PasswordSalt`).
- State assumptions first. With every aggregate, add a reconciliation check against the source table.
- If grain, a definition, a filter or the period is ambiguous, ask up to three questions before writing code.