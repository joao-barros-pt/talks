# Demo 5: the same task, in Copilot and in Claude

**Tools:** GitHub Copilot Chat (agent mode, MSSQL extension) and Claude Code, one after the other, full screen (the room can't read two panes)
**Language:** T-SQL on the SQL analytics endpoint of `bc_lab`
**Evidence:** `sql/02-company-key-trap.sql`

The same prompt, word for word, to both assistants. Twice: first in a cold window, then in this repository.

## Before you start

**Cold window.** A folder outside this repository, for example `C:\demos\cold-erp`, with one file, `schema.md`: the column list from check 10 of `sql/00-row-counts-by-company.sql` (table, column, type). Nothing else: no keys, no definitions, no `AGENTS.md`, no `CLAUDE.md`. Claude Code also reads `CLAUDE.md` from parent folders, so the cold folder must not sit inside the repository.

**Warm window.** This folder, with `AGENTS.md`, `CLAUDE.md` and `.github/copilot-instructions.md`.

In both: an SQL editor connected to the SQL endpoint, to run whatever comes back. New conversations (`/clear` in Claude Code). Claude Code writes the query; you run it with the MSSQL extension.

## The prompt

```text
Customer margin across all companies: customer, company, revenue, cost and margin.
T-SQL for the SQL analytics endpoint of the lakehouse bc_lab: dbo.customers, dbo.salesInvoices, dbo.generalLedgerEntries.
Then check the total.
```

If an assistant asks what cost means, answer with the definition only, and don't mention the company:

```text
Cost is the sum of debitAmount minus creditAmount in generalLedgerEntries on the cost of goods sold accounts <cogs-accounts>,
matched to the invoice through documentNumber.
```

## What each one should return

The right answer has the shape of check 5 in `sql/02-company-key-trap.sql`:

- `company` in **every** join: `customers` on `company` and `number`, the G/L entries on `company` and `documentNumber`.
- Cost aggregated per invoice **before** it is joined to the invoices.
- Posted invoices only (`Open`, `Paid`), revenue without tax.
- A check where revenue after the joins equals the source total, per company and overall.

## Where it usually fails

| Failure | What it does to the numbers |
|---|---|
| `JOIN dbo.customers AS c ON c.number = i.customerNumber`, no company | Every invoice finds the same customer in all four companies: revenue four times too big |
| G/L entries joined on `documentNumber` alone | The same invoice number exists in every company: cost about four times too big (not exactly: the extra invoices of each company share numbers, not amounts) |
| G/L entries joined line by line, then summed | Revenue repeated once per G/L line of the invoice |
| `totalAmountIncludingTax` | Revenue with tax |
| No status filter | Drafts counted as revenue |
| "Check the total" answered with a total of its own result | A check that can't fail. The total has to come from the source table |

In the cold window, the first failure is likely, not guaranteed. If both get it right, say so, ask each one how it knew the company belongs in the key, and run the evidence anyway: the point is the check, not the failure.

## What to point at

- Same prompt, same model of the data, different context. In the warm window the company is in the key because `AGENTS.md` says so.
- The query that multiplies runs without an error and gives a plausible number. Only the reconciliation shows it.
- Fill in after each rehearsal what each assistant actually did. Keep on the slide only what you saw.

| | Cold: company in the join? | Cold: total | Warm: company in the join? | Warm: total | Asked questions first? |
|---|---|---:|---|---:|---|
| GitHub Copilot | | n | | n | |
| Claude Code | | n | | n | |

## Evidence

Run checks 1 to 4 of `sql/02-company-key-trap.sql`: wrong join n, right join n, ratio 4.00 (`wrongOverRight`, when check 6 of `sql/00-row-counts-by-company.sql` shows every customer number in all four companies), and every company reconciling on its own.
