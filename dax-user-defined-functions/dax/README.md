# DAX queries

Every file runs on its own in Power BI Desktop, **DAX query view**, on the **Adventure Works DW 2020** sample model (<https://aka.ms/dax-docs-sample-file>). Each one starts with `DEFINE FUNCTION`, so nothing has to be in the model first.

| File | Demo | What it shows |
|---|---|---|
| `00-model-check.dax` | setup | Lines, orders and sales by fiscal year. Confirms the model before anything else |
| `01-first-function.dax` | 1 | `AW.PerOrder`: one rule, the grain, used by two measures |
| `02-val-vs-expr.dax` | 2 | `AW.ShareOfVal` against `AW.ShareOf`: same body, different passing mode |
| `03-reuse-everywhere.dax` | 2 | One `AW.ShareOf`, three measures, two different columns |
| `04-official-val-vs-expr.dax` | backup | Microsoft's own val vs expr example, on the same sample model |
| `05-optional-parameters.dax` | extra | `AW.PctChange` with a default parameter |
| `06-inspect-functions.dax` | extra | `INFO.USERDEFINEDFUNCTIONS` and `INFO.FUNCTIONS` |
| `07-change-a-rule.dax` | extra | A business rule changes: which measures call the function, before and after side by side, and the one-line change |

## The model, in four facts

- `Sales` is one row per **sales order line**. All amounts are in USD.
- `'Sales Order'[Sales Order]` is the order number. `'Sales Order'` is one-to-one with `Sales`.
- `Date` is marked as a date table. The fiscal year starts on 1 July. `'Date'[Fiscal Year]` holds values like `FY2020`.
- The sample has no measures. The files define the ones they need.

## What to expect

| File | Check |
|---|---|
| `00-model-check.dax` | 121,253 lines and 31,455 orders over the whole model, the same as in `prompting-for-data-people/dax/README.md` |
| `01-first-function.dax` | `Average Order Value` equals the per order column of `prompting-for-data-people/dax/aov-wrong-vs-right.dax`. The reconciliation row shows the same number twice |
| `02-val-vs-expr.dax` | `Share VAL` is 1 on every row. `Share EXPR` adds up to 1 |
| `04-official-val-vs-expr.dax` | 84,285 and 121,253, as the Microsoft article states |
| `05-optional-parameters.dax` | 0.1, -0.33 and BLANK in the first query |

## Keep them in the model

In DAX query view, **Update model with changes** saves every function and measure of the query into the model. The functions then appear under **Functions** in Model explorer, and in `definition/functions.tmdl` when the model is saved as a Power BI Project.
