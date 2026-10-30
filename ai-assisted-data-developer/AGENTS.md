# Project context

Demo repository for "The AI-Assisted Data Developer". AI assistants read this file at the start of every session. Keep it short and factual.

## Data sources

- Business Central online, sandbox environment `lab-sessoes`, four companies with the CRONUS evaluation data: `CRONUS Lisboa`, `CRONUS Porto`, `CRONUS Madrid`, `CRONUS London`.
- Read through the standard APIs v2.0, one call per company and entity, with the Power Query connector `Dynamics365BusinessCentral.ApiContentsWithOptions` (`powerquery/`).
- Landed by a Dataflow Gen2 in the Fabric workspace `LAB Sessoes`, lakehouse `bc_lab`, schema `dbo`. T-SQL runs on the lakehouse SQL analytics endpoint, which is read-only.
- Semantic model `Margin`, Direct Lake over `bc_lab`, saved as a Power BI Project in `model/`. The model definition (TMDL) is under `*.SemanticModel/definition/`.

## Grain: read before writing any join or aggregation

Every table has a `company` column. **The company is part of every key.** Numbers repeat across companies: customer `10000` exists in all four.

| Table | One row per | Key | Main columns |
|---|---|---|---|
| `dbo.customers` | customer, per company | `company` + `number` (also `customerKey`) | `displayName`, `currencyCode`, `blocked` |
| `dbo.items` | item, per company | `company` + `number` | `displayName`, `type`, `unitPrice`, `unitCost`, `itemCategoryCode` |
| `dbo.salesInvoices` | sales invoice header, per company (no lines) | `company` + `number` (also `invoiceKey`) | `invoiceDate`, `postingDate`, `customerNumber`, `currencyCode`, `totalAmountExcludingTax`, `totalTaxAmount`, `totalAmountIncludingTax`, `status` |
| `dbo.generalLedgerEntries` | G/L entry, per company | `company` + `entryNumber` | `postingDate`, `documentNumber`, `documentType`, `accountNumber`, `debitAmount`, `creditAmount` |

Model keys, built in Power Query because Direct Lake relationships can't use calculated columns:

- `customerKey` = `company & "|" & number` in `customers`, `company & "|" & customerNumber` in `salesInvoices`.
- `invoiceKey` = `company & "|" & number` in `salesInvoices`, `company & "|" & documentNumber` in `generalLedgerEntries`.

## Business definitions

To confirm against the real API fields in the lab (`sql/00-row-counts-by-company.sql` lists the values):

- **Posted invoice:** `salesInvoices.status` is `Open` or `Paid`. `Draft` and `In Review` are not posted. `Canceled` and `Corrective`: ask before including them.
- **Revenue:** `SUM(salesInvoices.totalAmountExcludingTax)` over posted invoices. Without tax. Amounts are in the invoice currency (`currencyCode`), which in the lab is the local currency of each company: EUR in `CRONUS Lisboa`, `CRONUS Porto` and `CRONUS Madrid`, GBP in `CRONUS London`. Sum per company or per currency. Never add up amounts in different currencies: for a group total, ask which conversion rate to use.
- **Cost:** `SUM(debitAmount - creditAmount)` of `generalLedgerEntries` on the cost of goods sold accounts listed in `model/snippets/00-starting-measures.tmdl`, for the entries of posted invoices only: matched to the invoice on `company` and `documentNumber`.
- **Gross margin:** revenue minus cost. **Gross margin %:** gross margin divided by revenue, blank when revenue is zero.
- **Date:** `postingDate` unless the request says otherwise.

## The key trap

A join on `customerNumber = number` without `company` matches each invoice to the same customer in every company. With four companies the total comes out four times too big, and the query runs without an error. The same holds for `documentNumber` against the G/L entries. Always join on `company` and the number, and reconcile per company.

## Conventions

- T-SQL: schema-qualified names (`dbo.salesInvoices`), explicit column lists (no `SELECT *`), ANSI joins, NULLs handled explicitly. The SQL endpoint is read-only: no DDL or DML.
- Power Query: one function, many companies. Never copy a query per company.
- DAX and TMDL: one measure per business definition, `DIVIDE` for ratios, a `///` description on every new measure and function. Tabs for indentation in `.tmdl` files.
- Do not select contact columns (`email`, `phoneNumber`, address lines), even in demo data.
- No secrets, tenant IDs or connection strings in files. Use placeholders such as `<tenant>`, `<environment>`, `<workspace-id>`.
- State assumptions at the top of the answer.
- With every aggregate, also give a reconciliation check: the parts per company add up to the total, and the total matches the source table.
- If grain, a business definition, a filter or the period is ambiguous, ask up to three questions before writing code.
