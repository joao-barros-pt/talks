# Setup checklist: AI-assisted data development on ERP data

What to have in place before the first prompt. The full steps are in the [README](../README.md), section Setup.

## Extensions and tools

- [ ] VS Code with **SQL Server (mssql)**, **GitHub Copilot**, **GitHub Copilot Chat**, **Claude Code** and **TMDL**.
- [ ] Git, and Python 3.10 or later for the Fabric CLI (`pip install ms-fabric-cli`, then `fab auth login`, interactive with a web browser).
- [ ] Power BI Desktop up to date. DAX user-defined functions need database compatibility level 1702 or higher (`compatibilityLevel` in `database.tmdl`).
- [ ] The model saved as a Power BI Project (`.pbip`) with the semantic model in TMDL (a `definition` folder, not `model.bim`).

## Context files

- [ ] `AGENTS.md` with the sources, the grain, the keys and the business definitions. For ERP data: the company is part of every key.
- [ ] `CLAUDE.md` that imports `AGENTS.md` (`@AGENTS.md`), plus the working rules for Claude Code (plan first, ask when ambiguous).
- [ ] `.github/copilot-instructions.md` with the same essentials, kept in sync with `AGENTS.md`.
- [ ] VS Code settings: `chat.useAgentsMdFile` and `github.copilot.chat.codeGeneration.useInstructionFiles` turned on.
- [ ] Claude Code: `/context` shows `CLAUDE.md` and `AGENTS.md` loaded.
- [ ] The session folder opened in VS Code, not the whole repository: context files only apply to the folder you open.

## Repository layout

```
AGENTS.md  CLAUDE.md  .github/
powerquery/   one function, N companies
fabric/       Dataflow Gen2, Direct Lake model, Fabric CLI commands
sql/          row counts per company and reconciliation queries
model/        the semantic model as TMDL, and reference snippets
prompts/      the exact prompts, one file per demo
checklist/    this file and the review checklist
```

- [ ] `.gitignore` covers local settings, caches, `*.pbix` and anything exported with IDs (`fabric/export/`).
- [ ] A tag for the starting state (`demo-start`) and a working branch (`demo/live`). Nothing goes to `main` without a pull request.

## Data and security

- [ ] Demo data only: CRONUS in a Business Central **sandbox** created empty, never copied from production.
- [ ] Interactive sign-in only. No passwords, keys, tokens, client secrets or tenant IDs in files, prompts or screenshots. Placeholders such as `<tenant>`, `<environment>`, `<workspace-id>`.
- [ ] Row counts per company checked after every load (`sql/00-row-counts-by-company.sql`), before any demo.

## Review

- [ ] Every change written with an assistant goes through [`ai-data-code-review-checklist.md`](ai-data-code-review-checklist.md) and a pull request before it reaches the workspace.
