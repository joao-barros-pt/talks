# DAX demo: average order value

Model: **Adventure Works DW 2020**, the DAX sample model from <https://aka.ms/dax-docs-sample-file> (also in [microsoft/powerbi-desktop-samples](https://github.com/microsoft/powerbi-desktop-samples/tree/main/DAX), MIT License).

Facts the demo relies on, from the model documentation:

- `Sales` is at **sales order line** grain. All amounts are in USD.
- `'Sales Order'` holds the order number (`'Sales Order'[Sales Order]`), the line number and the channel. It is one-to-one with `Sales`.
- `Date` is marked as a date table. The fiscal year starts on 1 July. Orders run from July 2017 to June 2020.

## The trap

Asked for "average order value", an assistant without context tends to write:

```dax
AOV = AVERAGE ( Sales[Sales Amount] )
```

That is the average **line** amount. The question is about **orders**:

```dax
Orders = DISTINCTCOUNT ( 'Sales Order'[Sales Order] )
AOV = DIVIDE ( SUM ( Sales[Sales Amount] ), [Orders] )
```

`aov-wrong-vs-right.dax` puts both side by side by fiscal year, with the line and order counts that explain the gap.

## What the evidence query returns

| Fiscal Year | Lines | Orders | Sales Amount | AOV per line (wrong) | AOV per order (right) |
|---|---:|---:|---:|---:|---:|
| FY2018 | 10,918 | 3,198 | 23,860,891.17 | 2,185.46 | 7,461.19 |
| FY2019 | 26,050 | 4,738 | 34,070,108.50 | 1,307.87 | 7,190.82 |
| FY2020 | 84,285 | 23,519 | 51,878,274.54 | 615.51 | 2,205.80 |

Over the whole model: 121,253 lines, 31,455 orders, 905.62 per line against 3,491.00 per order.

## Working from VS Code

Save the sample as a Power BI Project (.pbip). The model definition is written as TMDL files under `*.SemanticModel/definition/`, which Copilot and Claude Code can read as context. Write the measure in VS Code, then check the numbers with the DAX query above in Power BI Desktop.
