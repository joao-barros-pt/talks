# Copilot instructions

Keep in sync with `AGENTS.md` in this folder.

- Model: Adventure Works DW 2020 sample. `Sales` is one row per order line; `'Sales Order'[Sales Order]` is the order number. "Per order" divides by its distinct count.
- DAX user-defined functions: `FUNCTION <Name> = ( <param> : <type> <subtype> <mode> ) => <body>`. In TMDL, `function '<Name>'` in single quotes when the name has a dot.
- Namespace functions with `AW.`. Type every parameter. Use `EXPR` for any parameter the body evaluates under `CALCULATE`, `REMOVEFILTERS` or an iterator.
- `///` description right above each function. No recursion, no overloading.
- Never invent a column: check the TMDL files under `definition/`.
- With every new function, add a DAX query that compares it with the long-hand formula.
