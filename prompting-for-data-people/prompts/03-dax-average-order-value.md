# Demo 3: confident nonsense in DAX

**Tool:** GitHub Copilot Chat or Claude Code, in a copy of the Adventure Works DW 2020 project (.pbip) with **no** AGENTS.md or CLAUDE.md
**Language:** DAX
**Evidence:** `dax/aov-wrong-vs-right.dax` in Power BI Desktop's DAX query view

## Turn 1: the question as people usually ask it

```text
Add a DAX measure for average order value to this model.
```

Common answer:

```dax
Average Order Value = AVERAGE ( Sales[Sales Amount] )
```

It looks right, it is formatted, it has a confident explanation. It is the average **line** amount, because `Sales` is one row per order line.

## Evidence

Run `dax/aov-wrong-vs-right.dax`. Lines vs orders per fiscal year explain the gap between the two numbers.

## Turn 2: one sentence of context

```text
In this model, Sales is one row per order line and 'Sales Order'[Sales Order] is the order number.
Average order value is total Sales Amount divided by the number of distinct orders. Fix the measure.
```

Expected:

```dax
Orders = DISTINCTCOUNT ( 'Sales Order'[Sales Order] )
Average Order Value = DIVIDE ( SUM ( Sales[Sales Amount] ), [Orders] )
```

## If it gets it right the first time

Say so, then ask:

```text
How do you know this is per order and not per order line? Show me in the model where the grain comes from.
```

Run the evidence query anyway. The point of the demo is the check, not the failure.
