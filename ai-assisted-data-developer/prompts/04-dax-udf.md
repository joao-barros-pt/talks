# Demo 4: a DAX user-defined function, written with AI help

**Tool:** GitHub Copilot Chat (agent mode) or Claude Code, this folder open
**Language:** DAX user-defined functions in TMDL
**Reference answer:** `model/snippets/04-gross-margin-pct-function.tmdl`
**Evidence:** `git diff`, then `model/snippets/05-evidence-query.dax` once the model is published

## The prompt

```text
In the Margin model (model/Margin.SemanticModel), create a DAX user-defined function GrossMarginPct
with two numeric parameters, revenue and cost, that returns gross margin as a share of revenue,
blank when revenue is zero. Put it in definition/functions.tmdl.
Then add a measure Gross Margin % to the table salesInvoices that calls it with [Revenue] and [Cost], format 0.0%.
Use the current TMDL syntax for functions. If you are not sure of it, say so instead of guessing.
```

## What should come back

```tmdl
/// Gross margin as a share of revenue. Blank when revenue is zero or blank.
function GrossMarginPct =
		(revenue : NUMERIC, cost : NUMERIC) =>
			DIVIDE ( revenue - cost, revenue )
```

and, in `salesInvoices.tmdl`:

```tmdl
	measure 'Gross Margin %' = GrossMarginPct ( [Revenue], [Cost] )
		formatString: 0.0%
```

## Where it usually fails

DAX user-defined functions are recent, so expect invented syntax:

- A `DEFINE FUNCTION` block (that is the DAX query syntax) pasted into a `.tmdl` file.
- A return type (`RETURNS DECIMAL`): explicit return types are not supported.
- `DECIMAL` or `NUMBER` as a parameter type. `NUMERIC` is a subtype of `SCALAR`, and valid on its own.
- A name with a space, or a parameter name with a dot.
- `IF ( revenue = 0, BLANK (), ... )` instead of `DIVIDE`.
- The function written into `model.tmdl` or into the table file instead of `functions.tmdl`.

## What to point at

- The function is defined once and every measure that needs a margin ratio calls it.
- The "say so instead of guessing" line. Whether it admits doubt is worth more than the code.
- The check is not "it looks right": it is the project opening, the import succeeding and the evidence query matching `sql/02-company-key-trap.sql`.

## If it goes wrong

- The function doesn't load: check `compatibilityLevel` in `database.tmdl` (1702 or higher) and the tabs.
- Out of time: show `model/snippets/04-gross-margin-pct-function.tmdl` and the plan B slide.
