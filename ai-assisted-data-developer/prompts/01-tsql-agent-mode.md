# Demo 1: T-SQL with the MSSQL extension and Copilot in agent mode

**Tool:** GitHub Copilot Chat in VS Code, **agent mode**, with the SQL Server (mssql) extension
**Target:** SQL analytics endpoint of the lakehouse `bc_lab` (read-only)
**Reference answer:** `sql/01-demo1-revenue-by-company.sql`

## Before you start

- This folder open in VS Code, so Copilot reads `AGENTS.md` and `.github/copilot-instructions.md`.
- An empty SQL editor connected to the SQL endpoint (MSSQL extension, Microsoft Entra ID sign-in). The connection string comes from `fab get` (`fabric/cli-demo.md`, step 3).
- `sql/` and `prompts/` closed in the editor: they contain the answer.

## The prompt

```text
You're connected to the SQL analytics endpoint of the lakehouse bc_lab. Follow AGENTS.md.
Write a T-SQL query for revenue per company: company, number of posted invoices, revenue excluding tax.
State your assumptions first. Then write and run a reconciliation: the companies add up to the source total.
Read-only: no DDL, no DML.
```

## What usually comes back

- The assumptions, then a `GROUP BY company` over `dbo.salesInvoices` with a filter on `status`.
- In agent mode Copilot uses the MSSQL tools (connect, list databases, run query) and asks for approval on each one. Read the query before you approve the run.
- The reconciliation: the sum of the four companies against the total of the table.

## What to point at

- The schema came from the connection and the definitions from `AGENTS.md`. Nobody typed column names.
- The status filter. Without it, drafts count as revenue.
- The check was asked for in the prompt, before anyone saw a number.
- The currency: London in GBP, the other three in EUR. Revenue per company is right; the sum of the four is only a check.

## If it goes wrong

- It sums `totalAmountIncludingTax`: ask which amount `AGENTS.md` defines as revenue.
- It filters `status = 'Posted'`: that value doesn't exist. Run check 2 of `sql/00-row-counts-by-company.sql` and show the real values.
- Agent mode doesn't see the connection: `@mssql /connect`, or right-click the connection, **Chat with this database**.
- Nothing works: run `sql/01-demo1-revenue-by-company.sql` and show the plan B slide.
