# Project context

Demo repository for "DAX User-Defined Functions: Write Once, Reuse Everywhere". AI assistants read this file at the start of every session. Keep it short and factual.

## Data source

- Adventure Works DW 2020 sample model, saved as a Power BI Project. The model definition (TMDL) is under `*.SemanticModel/definition/`. User-defined functions are in `definition/functions.tmdl`.
- The model has no measures of its own. The queries in `dax/` define the ones they need.

## Grain: read before writing any aggregation

- `Sales`: one row per sales order line. All amounts in USD. `Sales[Sales Amount]` is the line amount.
- `'Sales Order'`: order number (`'Sales Order'[Sales Order]`), line number and channel. One-to-one with `Sales`.
- `Date`: marked as a date table. Three relationships with `Sales` (order, ship and due date); order date is the active one. Fiscal year starts on 1 July, `'Date'[Fiscal Year]` holds values like `FY2020`.
- "Per order" always divides by `DISTINCTCOUNT ( 'Sales Order'[Sales Order] )`, never by rows of `Sales`. Use `AW.PerOrder`.

## DAX user-defined functions

- Syntax: `FUNCTION <Name> = ( <param> : <type> <subtype> <mode> = <default> ) => <body>`. In TMDL: `function '<Name>' = ...`, name in single quotes when it has a dot.
- Namespace every function of this repository with `AW.` (`AW.PerOrder`, `AW.ShareOf`, `AW.PctChange`).
- Give every parameter a type hint. Use the most specific type: `NUMERIC`, `INT64`, `COLUMNREF`, `MEASUREREF`.
- A parameter that the body evaluates under `CALCULATE`, `REMOVEFILTERS` or an iterator must be `EXPR` (or a reference type). With `VAL` it arrives already evaluated and the new context has no effect.
- Put a `///` description on the line right above each function.
- No recursion and no overloading: they are not supported.
- Never invent a column. If a name is not in the TMDL files, ask.

## Conventions

- Format DAX with spaces inside parentheses and one argument per line when a call is long, as in `dax/`.
- With every new function, add a DAX query that tests it against the long-hand formula (see the reconciliation in `dax/01-first-function.dax`).
- State assumptions at the top of the answer.
- If the grain, a business definition or the period is ambiguous, ask up to three questions before writing code.
