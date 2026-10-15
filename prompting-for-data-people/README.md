# Prompting for Data People

Demos, prompts and takeaways from the session **Prompting for Data People: Getting Real Work Out of Copilot and Claude** (Cloud Data Driven User Group, 15 October 2026).

> Part of [talks](../README.md), the materials from my community sessions. Open this folder (`prompting-for-data-people`) in VS Code, not the whole repository: `AGENTS.md`, `CLAUDE.md` and `.github/copilot-instructions.md` only apply to the folder you open.

The session shows one repeatable method for data work with AI assistants, applied to T-SQL, DAX and Python:

| | Step | What you do |
|---|---|---|
| **S** | Schema and grain | Give the tables, columns, keys and what one row means. A few sample rows, never the whole database. |
| **C** | Constraints | Business definitions, filters, dialect and version, output format. |
| **O** | Open questions first | Ask the assistant to ask you questions before it writes code. |
| **P** | Patch, don't restart | Keep the conversation and change one thing at a time. |
| **E** | Evidence before trust | Reconcile totals, test edge cases, review with a checklist. |

## What's in here

```
setup/                            the demo database in one run: SQL Server 2016+, Azure SQL, Fabric
AGENTS.md                         shared project context, read by Copilot and other agents
CLAUDE.md                         imports AGENTS.md for Claude Code
.github/copilot-instructions.md   the same essentials for Copilot
context/                          schema card and the script that builds it
prompts/                          the exact prompts used in each demo
sql/                              sanity checks and reference queries (AdventureWorksLT)
dax/                              DAX query that proves the average order value trap
python/                           pandas fan-out trap with reconciliation checks, CSV files included
template/data-prompt-template.md  the reusable prompt template
checklist/ai-data-code-review-checklist.md   the review checklist
```

## Setup

### 1. AdventureWorksLT (T-SQL demos)

The quickest way, on any instance: create an empty database, connect to it and run `setup/00-create-adventureworkslt.sql` once. It creates the `SalesLT` schema with all ten tables and their rows in a single batch (no `GO`), inside one transaction, and ends with a check where every line must say OK. It runs on SQL Server 2016 or later, Azure SQL Database, Azure SQL Managed Instance and SQL database in Microsoft Fabric, and it can run again.

Other ways to get the same data:

- **SQL database in Microsoft Fabric**: create a new database and select **Sample data** on its home page. The option only appears on a brand-new, empty database.
- **Azure SQL Database**: create a database with the AdventureWorksLT sample as its data source.
- **SQL Server**: restore the AdventureWorksLT backup from Microsoft's sample databases.

Connect from VS Code with the **SQL Server (mssql)** extension and run `sql/00-sanity-checks.sql`. `context/build-schema-card.sql` needs SQL Server 2017 or later (it uses `STRING_AGG`).

### 2. Assistants in VS Code

- **GitHub Copilot** and **GitHub Copilot Chat**. With the MSSQL extension, the `@mssql` chat participant knows your connected database's schema. Inline completions (ghost text) do not.
- **Claude Code** (VS Code extension or terminal). `CLAUDE.md` imports `AGENTS.md`, so both assistants read the same context. Run `/context` to check which memory files were loaded.
- In VS Code, `AGENTS.md` is read when `chat.useAgentsMdFile` is enabled and `.github/copilot-instructions.md` when `github.copilot.chat.codeGeneration.useInstructionFiles` is enabled.

### 3. Adventure Works DW 2020 (DAX demo)

- Download the DAX sample model from <https://aka.ms/dax-docs-sample-file> and open it in Power BI Desktop. `dax/README.md` lists the numbers the evidence query should return.
- Save it as a **Power BI Project (.pbip)**. If the option or TMDL storage is still listed under **Options > Preview features**, enable it first.
- Open the project folder in VS Code. The model definition is in `*.SemanticModel/definition/`.
- Run `dax/aov-wrong-vs-right.dax` in Power BI Desktop's **DAX query view**.

### 4. Python (pandas demo)

```bash
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r python/requirements.txt
```

The two CSV files are already in `python/data/` (see `python/data/README.md` for the queries and the expected output). Run:

```bash
python python/fan_out_trap.py
```

### 5. Reproducing the "bad prompt" demos

Run the bad prompts from an empty folder outside this repository, with a copy of whatever files the prompt needs (the `.pbip` project, the two CSV files). Inside this repository the assistants read `AGENTS.md` and `CLAUDE.md`, which already state the grain and the definitions, so the mistakes may not show. Claude Code also reads `CLAUDE.md` from parent folders, so the empty folder must not sit inside the repository.

## Takeaways

- [`template/data-prompt-template.md`](template/data-prompt-template.md): the prompt template.
- [`checklist/ai-data-code-review-checklist.md`](checklist/ai-data-code-review-checklist.md): ten checks before AI-generated data code reaches production.

## Data

AdventureWorksLT and Adventure Works DW 2020 are Microsoft sample databases, published under the MIT License in [microsoft/sql-server-samples](https://github.com/microsoft/sql-server-samples) and [microsoft/powerbi-desktop-samples](https://github.com/microsoft/powerbi-desktop-samples). `setup/00-create-adventureworkslt.sql` carries the same rows as the official AdventureWorksLT backup, without the product photos and the XML catalog descriptions.

## Author

João Barros: AI & BI Consultant · Microsoft Certified Trainer (MCT) · Founder, bConcepts
