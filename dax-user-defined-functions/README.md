# DAX User-Defined Functions: Write Once, Reuse Everywhere

Demos and code from the session **DAX User-Defined Functions: Write Once, Reuse Everywhere**.

> Part of [talks](../README.md), the materials from my community sessions. Open this folder (`dax-user-defined-functions`) in VS Code, not the whole repository: `AGENTS.md`, `CLAUDE.md` and `.github/copilot-instructions.md` only apply to the folder you open.

| Delivered | Where | Format |
|---|---|---|
| Thursday, 19 November 2026 | Power BI & Fabric Barcelona user group, Plain Concepts, Barcelona | In person, 30 minutes, Spanish |

Slides and the recording are linked here after each delivery.

## The idea in one paragraph

The same logic ends up copied into twenty measures: a ratio, a "per order" rule, a share of total. A DAX user-defined function (UDF) writes that logic once, with typed parameters, and every measure calls it. Functions live in the semantic model, so they travel with it: in DAX query view, in TMDL view, in `functions.tmdl` inside a Power BI Project, and in Git.

```dax
DEFINE
    /// Divides an amount by the number of distinct sales orders.
    FUNCTION AW.PerOrder = ( amount : NUMERIC ) =>
        DIVIDE ( amount, DISTINCTCOUNT ( 'Sales Order'[Sales Order] ) )

EVALUATE
{ AW.PerOrder ( SUM ( Sales[Sales Amount] ) ) }
```

## What's in here

```
AGENTS.md                         project context for AI assistants: model, grain, conventions
CLAUDE.md                         imports AGENTS.md for Claude Code
.github/copilot-instructions.md   the same essentials for GitHub Copilot
dax/                              DAX queries for DAX query view, one per demo (DEFINE FUNCTION ... EVALUATE)
model/                            the same functions in TMDL: functions.tmdl and a createOrReplace script
SOURCES.md                        the documentation behind every claim in the session
```

## Setup

### 1. Power BI Desktop

- A Power BI Desktop release from **June 2026 or later**. DAX user-defined functions are generally available since that release.
- On an older release, the feature is a preview: **File > Options and settings > Options > Preview features > DAX user-defined functions**, then restart Power BI Desktop.
- The model needs **compatibility level 1702 or higher**.

### 2. The sample model

- Download **Adventure Works DW 2020** from <https://aka.ms/dax-docs-sample-file> (also in [microsoft/powerbi-desktop-samples](https://github.com/microsoft/powerbi-desktop-samples), MIT License).
- Open it, go to **DAX query view** and run `dax/00-model-check.dax`. `dax/README.md` says what it should return.

### 3. Functions in Git (demo 3)

- **File > Save as**, type **Power BI project files (*.pbip)**. The model definition is written as TMDL under `Adventure Works DW 2020.SemanticModel/definition/`, and the functions go to `functions.tmdl`.
- Open the project folder in VS Code with the **TMDL** extension. Its IntelliSense for user-defined functions is limited, so don't trust a red underline on its own: Power BI Desktop has the last word.
- Commit the project, change `functions.tmdl`, save, and accept the prompt in Power BI Desktop to apply the change.

## The demos

| Demo | Files | What you see |
|---|---|---|
| 1 · Your first function | `dax/01-first-function.dax` | `AW.PerOrder` in DAX query view, two measures that call it, then **Update model with changes** |
| 2 · One function, many measures | `dax/02-val-vs-expr.dax`, `dax/03-reuse-everywhere.dax` | The same function with `VAL` gives 100% everywhere. With `EXPR` it gives the real share. Then three measures from one function |
| 3 · Functions in TMDL and Git | `model/` | `functions.tmdl` in VS Code, a new function added as text, the diff in Git, the change applied in Power BI Desktop |

## Cheat sheet

```dax
FUNCTION <Name> = ( <param> : <type> <subtype> <mode> = <default>, ... ) => <body>
```

| Part | Values |
|---|---|
| Type | `AnyVal` (default), `Scalar`, `Table`, `AnyRef`, `CalendarRef`, `ColumnRef`, `MeasureRef`, `TableRef` |
| Scalar subtype | `Variant`, `Int64`, `Decimal`, `Double`, `String`, `DateTime`, `Boolean`, `Numeric` |
| Mode | `VAL`: evaluated once by the caller, before the function runs. `EXPR`: evaluated inside the function, where it is used. Reference types are always `EXPR` |
| Default | `= <expression>` makes a parameter optional |
| Names | Dots for namespaces (`AW.PerOrder`), otherwise letters, digits and underscores. No clash with built-in functions or reserved words |

**The one rule to remember:** if the function changes the filter context of a parameter (`CALCULATE`, `REMOVEFILTERS`, iterators), that parameter must be `EXPR`. With `VAL` it arrives as a finished number.

## Limits worth knowing

- No recursion, no overloading, no explicit return type.
- Functions can't be hidden, can't go into display folders and don't take translations.
- Object-level security does not carry over to functions. A function that uses a secured measure is not secured by itself, so keep secured names out of function names and descriptions.
- In a live-connected report, functions of the source model don't appear in Model explorer, and report measures that call them get no IntelliSense.
- Visual calculations can call functions, but only with fields that are in the visual.

The full list is in [SOURCES.md](SOURCES.md).

## Want more functions?

[DAX Lib](https://daxlib.org), a free project by SQLBI, collects libraries of model-independent DAX functions. Copy a library's TMDL into TMDL view, or use the DAX Package Manager in Tabular Editor 3.

## Data

Adventure Works DW 2020 is a Microsoft sample model, published under the MIT License in [microsoft/powerbi-desktop-samples](https://github.com/microsoft/powerbi-desktop-samples). It holds no real customer data.

## Author

João Barros: AI & BI Consultant · Microsoft Certified Trainer (MCT) · Founder, bConcepts
