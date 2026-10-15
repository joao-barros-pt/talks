# Code review checklist for AI-generated data code

Ten checks before T-SQL, DAX or Python written with an assistant reaches production.
Most of the confident nonsense lives in the first four.

1. **Grain.** What does one row mean at each step? Is the result at the grain the question asks for: orders, lines, customers, days?
2. **Joins.** Can this join multiply rows (one-to-many)? Did the row count or a total change after the join?
3. **NULLs.** What happens to rows with a NULL in a filtered, joined or aggregated column? Watch `<>`, `NOT IN`, `AVG`, `COUNT(column)` and DAX blanks.
4. **Definitions.** Does "revenue", "customer" or "order" match the business definition, or only the column name?
5. **Filters and dates.** Inclusive or exclusive boundaries, the time portion of datetimes, time zones, fiscal or calendar year.
6. **Totals reconcile.** Do the parts add up to the source total? Write the check before you read the result.
7. **Edge cases.** Empty period, a single row, duplicates, a zero denominator (`NULLIF`, `DIVIDE`).
8. **Names exist.** Every table, column and function exists in your version. Assistants invent plausible columns.
9. **Safety and performance.** No data changes you did not ask for, no `SELECT *`, filters that can use an index, no secrets or personal data in the prompt.
10. **Explain it.** Can you explain the code to a colleague in two sentences? If not, it is not ready.
