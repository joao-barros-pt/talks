# Functions in TMDL

The same functions as in `../dax/`, written as TMDL. Use them in one of two ways.

| File | What it is | Where it goes |
|---|---|---|
| `functions.tmdl` | The file as a Power BI Project stores it: every user-defined function of the model in one file | `Adventure Works DW 2020.SemanticModel/definition/functions.tmdl` |
| `createOrReplace-functions.tmdl` | A TMDL script with `AW.PerOrder` and `AW.ShareOf` | Paste into **TMDL view** in Power BI Desktop and click **Apply** |
| `demo3-add-pctchange.tmdl` | The block added live in demo 3 | Paste at the end of `functions.tmdl` in VS Code |

## Rules that bite

- In TMDL, an object name with a dot must be in single quotes: `function 'AW.PerOrder'`. In DAX you call it without quotes: `AW.PerOrder ( [Total Sales] )`.
- TMDL indents with tabs. The expression of a multi-line function starts on the next line, one level deeper than the properties.
- The `///` lines go right above `function`, with no blank line in between. They become the description you see in IntelliSense.
- When Power BI Desktop saves the model it may add properties of its own to each function (such as a `lineageTag`). These files leave them out; Desktop writes its own.
- User-defined functions need compatibility level 1702 or higher. Check `compatibilityLevel` in `database.tmdl`.

## Working with Git

1. Save the sample model as a Power BI Project (.pbip).
2. Open the project folder in VS Code and commit it as it is.
3. Change `functions.tmdl`, save, and Power BI Desktop offers to apply the change.
4. The commit shows one function as a few lines of diff, not a binary file.
