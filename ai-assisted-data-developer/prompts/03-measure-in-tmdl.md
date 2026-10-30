# Demo 3: a new measure, written as code

**Tool:** Claude Code (VS Code extension or terminal), this folder open
**Language:** TMDL and DAX
**Reference answer:** `model/snippets/03-gross-margin-measure.tmdl`
**Evidence:** `git diff`

## Before you start

- On the branch `demo/live`, at the tag `demo-start`. `git status` is clean.
- `model/Margin.SemanticModel/` is the exported Power BI Project of the starting model.
- `model/snippets/` closed in the editor.
- New Claude Code session (`/clear`). `CLAUDE.md` makes it show a plan and wait.

## The prompt

```text
In the Margin model (model/Margin.SemanticModel), add a measure Gross Margin to the table salesInvoices:
Revenue minus Cost, format #,0.00, with a /// description. Use the existing Revenue and Cost measures.
Change nothing else.
```

## What usually comes back

- A short plan: which file (`definition/tables/salesInvoices.tmdl`), what goes in, what stays untouched. Read it, then say go.
- Three lines of TMDL: the description, the measure, the format string.

## What to point at

- The model is a folder of text files. The assistant edited one of them, like any source file.
- `git diff` shows exactly what changed. That diff is what a reviewer reads in demo 6.
- Indentation is one tab per level, like the rest of the file. A measure that breaks the indentation doesn't parse.

## If it goes wrong

- It recalculates revenue and cost inside the new measure instead of reusing `[Revenue]` and `[Cost]`: ask why. One definition, one measure.
- It touches other files (reformats `model.tmdl`, adds lineage tags everywhere): `git restore` those files and ask again with "Change nothing else" in bold.
- It skips the plan: say "Plan first", and point at `CLAUDE.md`.
