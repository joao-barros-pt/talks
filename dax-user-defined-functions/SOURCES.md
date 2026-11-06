# Sources

Every technical claim in the session and in this folder comes from the pages below. Checked on 27 October 2026.

## Microsoft documentation

| Page | Used for |
|---|---|
| [DAX user-defined functions](https://learn.microsoft.com/dax/best-practices/dax-user-defined-functions) (last updated 2 June 2026) | General availability from the June 2026 release; compatibility level 1702; syntax in DAX query view and TMDL; types, subtypes and the `VAL`/`EXPR` table; 0 to 256 parameters; default parameters; naming rules; type-checking functions; `INFO.USERDEFINEDFUNCTIONS` and `INFO.FUNCTIONS`; where functions can be used; the full list of limitations; the `CountRowsNow` / `CountRowsLater` example and its result (84285, 121253) on the sample model |
| [Using DAX user-defined functions (Power BI)](https://learn.microsoft.com/power-bi/transform-model/desktop-user-defined-functions-overview) (last updated 9 July 2026) | **Update model with changes** in DAX query view; **Apply** in TMDL view; the **Functions** node in Model explorer and its quick queries; `functions.tmdl` in the *definition* folder; calling a function from a measure, a calculated column and a visual calculation |
| [FUNCTION statement (DAX)](https://learn.microsoft.com/dax/function-statement-dax) | Formal syntax of `FUNCTION` inside `DEFINE` |
| [DAX queries](https://learn.microsoft.com/dax/dax-queries) | `DEFINE` with `MEASURE`, `VAR`, `TABLE`, `COLUMN`; column names of the sample model used in examples (`'Date'[Fiscal Year]`, `'Product'[Category]`, `'Sales Order'[Sales Order]`) |
| [DAX sample model](https://learn.microsoft.com/dax/dax-sample-model) | Tables of Adventure Works DW 2020; `Sales` at order line grain; `Date` marked as date table, fiscal year from 1 July; three date relationships; no DAX formulas in the sample |
| [Previous monthly updates to Power BI Desktop](https://learn.microsoft.com/power-bi/fundamentals/desktop-latest-update-archive) | June 2026: user-defined functions generally available, optional parameters. March 2026: up to 256 parameters (from 12), `INFO.USERDEFINEDFUNCTIONS`. April 2026: `NAMEOF` options. March and July 2026: TMDL view on the web |
| [Tabular Model Definition Language (TMDL)](https://learn.microsoft.com/analysis-services/tmdl/tmdl-overview) | `functions.tmdl`, one file for all functions; tab indentation; `///` descriptions; single quotes around names with a dot; multi-line expression rules |
| [Power BI Desktop projects (PBIP)](https://learn.microsoft.com/power-bi/developer/projects/projects-overview) (last updated 23 September 2026) | Folder structure; the `.gitignore` Power BI Desktop creates (`**/.pbi/localSettings.json`, `**/.pbi/cache.abf`); "When you save changes to project files outside Power BI Desktop, Power BI Desktop detects the changes and prompts you to apply them" |
| [Power BI Desktop project semantic model folder](https://learn.microsoft.com/power-bi/developer/projects/projects-dataset) | The `definition` folder holds the model as TMDL and replaces `model.bim` |

## Power BI blog

| Post | Used for |
|---|---|
| [DAX UDFs: Code once, reuse everywhere (Preview)](https://asia.powerbi.microsoft.com/en-ie/blog/dax-udfs-code-once-reuse-everywhere-preview), Jeroen ter Heerdt, announced with the September 2025 feature summary | The public preview and its switch in **Options > Preview features**; first examples in DAX query view and TMDL |

## Community

| Page | Used for |
|---|---|
| [Understanding parameter types in DAX user-defined functions](https://www.sqlbi.com/articles/understanding-parameter-types-in-dax-user-defined-functions-udf/), SQLBI, 20 April 2026 | `COLUMNREF` and `MEASUREREF` in practice; use the most specific type; `SCALAR` and `TABLE` work with both `VAL` and `EXPR` |
| [Using REMOVEFILTERS in DAX user-defined functions](https://www.sqlbi.com/articles/using-removefilters-in-dax-user-defined-functions/), SQLBI, 29 June 2026 | Functions are macro-expanded; an `EXPR` parameter evaluated inside `CALCULATE` |
| [Introducing DAX Lib](https://www.sqlbi.com/blog/marco/2025/12/12/introducing-dax-lib-the-app-store-for-dax-user-defined-functions/), SQLBI, 12 December 2025 | [daxlib.org](https://daxlib.org): libraries of functions, installed by pasting TMDL into TMDL view |
| [Introducing the DAX Package Manager in Tabular Editor](https://tabulareditor.com/blog/introducing-the-dax-package-manager-in-tabular-editor), 2 December 2025 | Installing DAX Lib packages from Tabular Editor 3 |
| [Install DAX libraries into Power BI Desktop by asking your AI assistant](https://www.sqlbi.com/blog/marco/2026/10/22/install-dax-libraries-into-power-bi-desktop-by-asking-your-ai-assistant/), SQLBI, 22 October 2026 | The DAX Lib MCP server (Windows x64, models open in Power BI Desktop, compatibility level 1702) |

## Still to confirm in the lab

- `REMOVEFILTERS ( scopeColumn )` with a `COLUMNREF` parameter, in `AW.ShareOf`. The Microsoft article warns that passing columns as `EXPR` parameters can show red underlines that are not real errors.
- Whether Power BI Desktop raises the compatibility level of the sample model on its own when the first function is saved.
- The serialized form of `functions.tmdl` after Power BI Desktop saves it (indentation and any `lineageTag`), compared with the files in `model/`.
- The exact column names `'Date'[Date]` (used in `05-optional-parameters.dax`) and the four values of `'Product'[Category]`: the Microsoft pages name the Date column the table is marked with, but list no column values.
