# Code review checklist for AI-generated data code: ERP edition

Ten checks before T-SQL, Power Query, DAX or TMDL written with an assistant reaches the workspace.
Most of the confident nonsense lives in the first four.

1. **Grain.** What does one row mean at each step: one invoice per company, one G/L entry per company, one customer per company? Is the result at the grain the question asks for?
2. **Joins.** Is the company in every join? Can this join multiply rows (one invoice, many G/L lines)? Did a row count or a total change after the join?
3. **NULLs.** Blank dimension values, DAX blanks, `NOT IN`. Invoices without a customer, G/L entries without a document number, an empty `currencyCode`.
4. **Definitions.** Posting date or document date? Which revenue: with or without tax, posted or draft? Which accounts are cost? In which currency? Does it match `AGENTS.md`, or only the column name?
5. **Filters and dates.** Inclusive or exclusive boundaries, the time part of datetimes, fiscal or calendar year, the status values as they are really stored.
6. **Totals reconcile.** Per company first, then combined. The parts add up to the source table, not to the query's own result. Write the check before you read the result.
7. **Edge cases.** A company with no invoices, a company added tomorrow, duplicates in a key, a zero denominator (`NULLIF`, `DIVIDE`).
8. **Names exist.** Every table, column, API field, enum value and function exists in your version. Assistants invent plausible fields (`amountExcludingTax`, `status = 'Posted'`) and plausible syntax for recent features such as DAX user-defined functions.
9. **Safety and performance.** No data changes you did not ask for, no `SELECT *`, no contact columns, no production data, no secrets, tenant IDs or connection strings in the code, the prompt or the commit.
10. **Explain it.** Can you explain the change to a colleague in two sentences, and say which number proves it? If not, it is not ready.
