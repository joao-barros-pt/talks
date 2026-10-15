# Demo 2: make it ask you, then patch instead of restarting

**Tool:** Claude Code in VS Code, this repository open (CLAUDE.md imports AGENTS.md)
**Language:** T-SQL on AdventureWorksLT
**Reference answers:** `sql/02-aov-per-customer.sql`

## Turn 1: open questions first

```text
I want the average order value per customer from the SalesLT schema.
Before you write any SQL, ask me up to three questions about anything ambiguous. Don't guess.
```

Questions you can expect, and the answers to give:

| Likely question | Answer |
|---|---|
| Which period? | All orders in the table. |
| Include customers with no orders? | Not for now, only customers with at least one order. |
| Rounding, currency, sort order? | Round to two decimals in the output only, highest first. |

It should not need to ask about tax and freight: `AGENTS.md` already defines order value as `SubTotal`. If it asks anyway, answer SubTotal and point out that the answer is already written down.

## Turn 2: patch

```text
Keep the query exactly as it is. Add each customer's rank by total order value and their share of the total.
Show me only the lines you changed.
```

## Turn 3: patch again

```text
Now include customers with no orders, with 0 orders and 0 order value. Don't change anything else.
```

Watch for the switch to a LEFT JOIN and for the division by zero in the average.

## Turn 4: evidence

```text
Give me a query that proves the per-customer values add up to the header total.
```

## What to point at

- The three questions are exactly where a wrong answer would have come from.
- Each patch kept the context the first turn paid for. Starting over would have meant explaining the grain and the definitions again.
- The question it did not ask: tax and freight. The definition is in AGENTS.md, so there was nothing to ask.
- "Ask questions when ambiguous" is also written in CLAUDE.md, so it applies in every session without typing it.
