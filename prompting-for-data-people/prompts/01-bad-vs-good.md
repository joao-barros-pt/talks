# Demo 1: the same question, asked badly and asked well

**Tool:** GitHub Copilot Chat in VS Code, Ask mode
**Language:** T-SQL on AdventureWorksLT
**Reference answer:** `sql/01-revenue-by-top-category.sql`

## Bad (cold window: an empty folder, no instruction files, no `@mssql`)

```text
Write a SQL query that shows revenue by product category.
```

What usually comes back: tables from the full AdventureWorks (`Sales.SalesOrderDetail`, `Production.Product`, ...) or a generic `orders` table, revenue from whatever column looks right, and categories at the wrong level. It reads well and fails on the first run, or runs and answers a different question.

## Good (this repository open, connected to the database)

```text
@mssql Use the schema card in #file:context/schema-card-adventureworkslt.md.
Write a T-SQL query for revenue by top-level product category.
- Revenue = SUM(SalesLT.SalesOrderDetail.LineTotal).
- Top-level category = the parent of the product's category (two-level hierarchy through ParentProductCategoryID).
- Return TopCategory, Revenue and Orders (distinct SalesOrderID), sorted by Revenue descending.
- Then give me a query that checks the grand total against SalesOrderDetail.
```

## What to point at

- The bad prompt gave the model nothing but a sentence. It filled the gaps with the most common AdventureWorks it has seen.
- The good prompt is not longer for the sake of it: every line removes one guess (schema, definition, hierarchy, output, evidence).
- `@mssql` sees the connected schema. Inline ghost-text completions don't.
