# Demo 4 (short, or backup): the fan-out trap in pandas

**Tool:** GitHub Copilot Chat in VS Code, in the cold window: a folder outside this repository with a copy of the two CSV files under `python/data/` and no instruction files. In this repository, AGENTS.md states the grain and asks for a reconciliation check, so the trap may not show.
**Language:** Python with pandas
**Evidence:** `python/fan_out_trap.py`

## Turn 1: the question as people usually ask it

```text
Using python/data/SalesOrderHeader.csv and python/data/SalesOrderDetail.csv,
write pandas code that gives total revenue per customer including tax and freight. Use both files.
```

Common answer: merge the two files on SalesOrderID, then `groupby("CustomerID")["TotalDue"].sum()`.
TotalDue is a header value, repeated on every line after the merge, so the totals are inflated.

## Turn 2: ask for evidence, not reassurance

```text
Add a check that the per-customer totals add up to the sum of TotalDue in SalesOrderHeader.csv,
and a check that SalesOrderID is unique in the frame you sum TotalDue from.
```

The checks fail on the merged version. That is the moment to show `python/fan_out_trap.py`.

## Turn 3: fix with grain

```text
TotalDue lives on the order header, one row per order. Aggregate it at that grain. Keep the checks.
```
