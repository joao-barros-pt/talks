# The model as code: demos 3 and 4

The semantic model `Margin` (Direct Lake over the lakehouse `bc_lab`) lives here as a Power BI Project. Its definition is plain text in TMDL, so it diffs, reviews and rolls back like any other code.

```
model/
  Margin.SemanticModel/           exported from Power BI Desktop (fabric/README.md, "Save it as code")
    definition/
      database.tmdl               compatibilityLevel: 1702 or higher for DAX user-defined functions
      model.tmdl
      relationships.tmdl          customerKey and invoiceKey
      functions.tmdl              appears with the first user-defined function (demo 4)
      expressions.tmdl            the Direct Lake connection: replace IDs with placeholders before a public push
      tables/
        customers.tmdl
        items.tmdl
        salesInvoices.tmdl        Revenue, then Gross Margin (demo 3) and Gross Margin % (demo 4)
        generalLedgerEntries.tmdl Cost
  snippets/                       the reference answers. Keep them closed during the demos
```

`Margin.SemanticModel/` is not shipped in the public folder: its connection points to your own workspace and lakehouse. You create it in the lab and commit it in your private copy before the tag `demo-start` (README, Security).

## Power BI Desktop settings

- Power BI Desktop up to date. DAX user-defined functions are generally available since the June 2026 release. On an older version, update rather than look for a preview switch.
- The project saves the model as TMDL (a `definition` folder, not `model.bim`). If the PBIP save option or TMDL storage is still listed under **File > Options and settings > Options > Preview features**, enable it and restart Power BI Desktop.
- TMDL view is available while live editing a Direct Lake model.

## Snippets

| File | Demo | What it is |
|---|---|---|
| `snippets/00-starting-measures.tmdl` | before demo 3 | `Revenue` and `Cost`, the starting state. Fill in the cost of goods sold accounts |
| `snippets/03-gross-margin-measure.tmdl` | 3 | One new measure, `Gross Margin`, in `salesInvoices.tmdl` |
| `snippets/04-gross-margin-pct-function.tmdl` | 4 | The function `GrossMarginPct` and the measure `Gross Margin %` that calls it |
| `snippets/05-evidence-query.dax` | 4 and 6 | DAX query: the numbers per company and for the group, to reconcile with `sql/02-company-key-trap.sql` |

Copy the blocks, not the `//` comment lines: they explain the snippet and are not TMDL.

## TMDL rules that bite

- Indentation is one **tab** per level (the TMDL default): object, then properties, then multi-line expressions. Breaking the indentation rules gives a parsing error, and pasting from a chat window often turns tabs into spaces.
- A `///` line right above a measure or function is its description.
- A multi-line expression goes one level deeper than the properties, or between triple backticks.
- Function names take letters, digits, underscores and dots (`Lab.GrossMarginPct` is valid). No spaces. Parameter names take no dots.
- `NUMERIC` on a parameter is short for a scalar numeric value. Passing mode `VAL` evaluates the argument before the function runs; `EXPR` evaluates it inside the function. The two measures passed to `GrossMarginPct` only need `VAL`.

## Demo 3 · A measure in TMDL

1. VS Code, this folder open. `git status` is clean, on the branch `demo/live`.
2. Claude Code, with `prompts/03-measure-in-tmdl.md`. Read its plan before it edits.
3. `git diff`: one measure in `definition/tables/salesInvoices.tmdl`, nothing else.

## Demo 4 · A DAX user-defined function

1. Same window. Copilot or Claude Code, with `prompts/04-dax-udf.md`.
2. `git diff`: `functions.tmdl` with `GrossMarginPct`, and one measure in `salesInvoices.tmdl`.
3. If `database.tmdl` shows a compatibility level below 1702, the function won't load: raise it in the lab, before the session, and commit it as part of the starting state.

The changes are published to the workspace only after the pull request of demo 6 (`fabric/cli-demo.md`, step 6). Then run `snippets/05-evidence-query.dax` in DAX query view.

## Expected numbers

| Company | Revenue | Cost | Gross Margin | Gross Margin % |
|---|---:|---:|---:|---:|
| CRONUS Lisboa | n | n | n | n |
| CRONUS Porto | n | n | n | n |
| CRONUS Madrid | n | n | n | n |
| CRONUS London | n | n | n | n |
| All companies | n | n | n | n |

Filled in after the lab run, from `sql/02-company-key-trap.sql` (check 5) and `snippets/05-evidence-query.dax`. They must agree.

London is in GBP and the other three companies in EUR. The **All companies** row adds both currencies: it checks that the companies add up, it is not a revenue figure.

To compare with the lab run, Business Central on 27 October (chart of accounts: revenue without tax and net of discounts, cost on account 7190):

| Company | Revenue | Cost | Gross Margin % |
|---|---:|---:|---:|
| CRONUS Lisboa (EUR) | 661,606.95 | 503,101.20 | 24.0% |
| CRONUS Porto (EUR) | 585,125.55 | 458,426.70 | 21.7% |
| CRONUS Madrid (EUR) | 574,605.85 | 465,974.40 | 18.9% |
| CRONUS London (GBP) | 549,102.35 | 423,316.20 | 22.9% |
