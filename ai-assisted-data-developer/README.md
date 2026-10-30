# The AI-Assisted Data Developer

Lab kit, demos, prompts and takeaways from the session **The AI-Assisted Data Developer**, in two variants:

- **ERP variant:** *Building the Analytics Layer on ERP Data with Copilot and Claude*. Business Central data, from the API to OneLake to a semantic model.
- **General variant:** *VS Code, Copilot & Claude Across Fabric, Power BI and SQL Server*. The same lakehouse and the same demos, without the Business Central part.

> Part of [talks](../README.md), the materials from my community sessions. Open this folder (`ai-assisted-data-developer`) in VS Code, not the whole repository: `AGENTS.md`, `CLAUDE.md` and `.github/copilot-instructions.md` only apply to the folder you open.

## Where it is given

| Date | Event | Variant | Format |
|---|---|---|---|
| 12 November 2026 | SQL Server User Group Croatia | General | online |
| 14 November 2026 | AI Virtual Days | General | online |
| 27 November 2026 | Dynamics 365 AI ERP Summit, Microsoft Expo Lisbon | ERP | in person, 60 minutes |
| 29 November 2026 | Microsoft Fabric User Group Pune | General | online, 45 minutes |

Slides (PDF) and recordings are added here after each session.

## What the session covers

One business request, built end to end without leaving VS Code:

> Gross margin by company and customer, every morning, comparable across all our companies.

| # | Demo | Where | What it shows |
|---|---|---|---|
| 1 | T-SQL with the MSSQL extension and Copilot in agent mode | SQL analytics endpoint of the `bc_lab` lakehouse | Revenue per company, with a reconciliation written before the result |
| 2 | Fabric CLI: list and publish workspace items | terminal | `fab ls`, `fab get`, `fab export` and `fab import` against the `LAB Sessoes` workspace |
| 3 | The model as code: a new measure in TMDL and the diff in Git | VS Code | The semantic model is a folder of text files |
| 4 | DAX with a user-defined function written with AI help | TMDL | `GrossMarginPct`, a function the measures reuse |
| 5 | The same task in Copilot and in Claude, with the live failure | VS Code | Customer `10000` exists in all four companies. A join on the number alone multiplies the total by four |
| 6 | Guardrails: review checklist and pull request before the workspace | GitHub | No AI-generated code reaches the workspace unreviewed |

## What you take home

```
AGENTS.md                         shared project context: sources, grain, definitions, the company key
CLAUDE.md                         imports AGENTS.md for Claude Code, plus two working rules
.github/copilot-instructions.md   the same essentials for GitHub Copilot
.github/pull_request_template.md  the pull request template from demo 6
powerquery/                       fnCompanyTable, AllCompanies and the four entity queries (one query, N companies)
fabric/                           Dataflow Gen2 to the lakehouse, Direct Lake model, and the Fabric CLI commands of demo 2
sql/                              row counts per company, the demo 1 query, and the company key trap
model/                            TMDL snippets: the starting measures, the demo 3 measure, the demo 4 function
prompts/                          the exact prompts of each demo (01 to 06), including the one both assistants get in demo 5
checklist/                        the setup checklist, and ten checks before AI-generated data code reaches production, ERP edition
```

## Before you start

**Who does what.** The administration steps (Business Central admin center, Azure subscription and Fabric capacity, Fabric admin portal, tenant settings, permissions) are for whoever runs the lab, with their own admin rights. Nothing in this repository changes tenant settings for you.

**Demo data only.** Everything here runs on the CRONUS evaluation data in a Business Central **sandbox**. Never copy a production environment into the lab and never point these queries at customer data.

Prerequisites:

- A Microsoft Entra ID work account with access to Business Central online (a sandbox you can create) and to Microsoft Fabric.
- A Fabric capacity (an F SKU; F2 is enough) or a Fabric trial. Direct Lake models need a Fabric capacity.
- Windows with Power BI Desktop up to date.
- VS Code, Git, Python 3.10 or later.
- A GitHub account with GitHub Copilot, and Claude Code.

## Setup

### 1. Business Central sandbox (admin)

1. Business Central admin center, **Environments**, **New**.
2. Name `lab-sessoes`. Environment type: **Sandbox**. Version: the latest one that is **not** a preview.
3. Do **not** use Copy from production. A copied sandbox brings real data.
4. Wait until the state is **Active**.

### 2. Four demo companies (admin)

Three companies in euros and one in pounds, on purpose: revenue per company is fine, a total across the four is not until it is converted.

1. `CRONUS London`, in GBP: **Companies**, **New**, **Create New - No Data**. In the new company, the **Contoso Demo Tool** generates the sample data (country GB). Its local currency is GBP.
2. A base company in EUR for the other three: **Create New - No Data** again, and in the Contoso Demo Tool run **Generate Setup Data** first. That step sets the local currency to GBP, so change it right after, in the same session: **General Ledger Setup**, LCY Code `EUR`, symbol `€`, description `Euro`. Then go back and generate the rest. The local currency can't change once there are G/L entries.
3. **Companies**, **Copy**, three times from the EUR base: `CRONUS Lisboa`, `CRONUS Porto` and `CRONUS Madrid`.
4. Make the four different, so the totals are not multiples of each other: post sales orders and draft invoices in different numbers per company, a services invoice (resources, so no cost of goods sold) where the margin should go up, and a discounted deal where it should go down. Use existing customers and items, never a new customer in one company only: the key trap of demo 5 relies on every customer number existing in all four companies (check 6 of `sql/00-row-counts-by-company.sql`).
5. In the lab on 27 October, Business Central showed 319 posted invoices in Lisboa, 307 in Porto, 303 in Madrid and 299 in London, with a gross margin of 24.0%, 21.7%, 18.9% and 22.9%. Check 3 of `sql/00-row-counts-by-company.sql` shows the currency of each company.

### 3. Fabric: capacity, workspace, lakehouse (admin)

1. A Fabric capacity, F2 pay-as-you-go in your own Azure subscription (pause it after every session) or a Fabric trial.
2. Workspace `LAB Sessoes`, assigned to that capacity.
3. Lakehouse `bc_lab`.
4. For live editing the Direct Lake model in Power BI Desktop: XMLA endpoints allowed in the tenant settings and **Read Write** on the capacity.
5. Pause the capacity at the end.

### 4. From Business Central to OneLake

Full steps in [`fabric/README.md`](fabric/README.md). In short:

1. **Power Query, the pattern.** `powerquery/fnCompanyTable.pq` reads one API v2.0 entity from one company and adds a `company` column. `powerquery/AllCompanies.pq` applies it to the four companies and the four entities. `powerquery/entity-queries.pq` turns the result into four tables with the model keys.
2. **Dataflow Gen2** in `LAB Sessoes` with the same queries, each with the lakehouse `bc_lab` as data destination: tables `customers`, `items`, `salesInvoices` and `generalLedgerEntries`, each with the `company` column.
3. **Semantic model** `Margin` in Direct Lake over `bc_lab`, exported as a Power BI Project (PBIP) to `model/`.

### 5. Power BI Desktop: PBIP with TMDL

- The model is saved as a **Power BI Project (.pbip)** with the semantic model in **TMDL** (a `definition` folder). If the PBIP save option or TMDL storage is still listed under **Options > Preview features**, enable it first.
- DAX user-defined functions are generally available since the June 2026 release of Power BI Desktop and need database compatibility level 1702 or higher. Check `compatibilityLevel` in `database.tmdl`.

### 6. VS Code and extensions

- **SQL Server (mssql)**, **GitHub Copilot**, **GitHub Copilot Chat**, **Claude Code** and **TMDL**.
- With the MSSQL extension, the `@mssql` chat participant and agent mode know the schema of the connected database. Agent mode asks for approval before each tool it runs.
- In VS Code settings, turn on `chat.useAgentsMdFile` (reads `AGENTS.md`) and `github.copilot.chat.codeGeneration.useInstructionFiles` (reads `.github/copilot-instructions.md`).
- In Claude Code, run `/context` and check that `CLAUDE.md` and `AGENTS.md` are loaded.

### 7. Fabric CLI

```bash
pip install ms-fabric-cli
fab --version
fab auth login        # choose "Interactive with a web browser"
fab auth status
```

The commands of demo 2 are in [`fabric/cli-demo.md`](fabric/cli-demo.md).

### 8. Check the data

Connect the MSSQL extension to the SQL analytics endpoint of `bc_lab` (the connection string comes from `fab get`, see `fabric/cli-demo.md`) and run `sql/00-row-counts-by-company.sql`. Write the numbers down: they are the ones the demos must show.

| Table | CRONUS Lisboa | CRONUS Porto | CRONUS Madrid | CRONUS London |
|---|---:|---:|---:|---:|
| customers | n | n | n | n |
| items | n | n | n | n |
| salesInvoices | n | n | n | n |
| generalLedgerEntries | n | n | n | n |

`n` marks numbers that only the lab can give. They are filled in after the lab run, never estimated.

## The demos

The exact prompts are in [`prompts/`](prompts/). Copy and paste them, don't improvise live. Keep `sql/`, `model/snippets/` and `prompts/` closed in VS Code while a demo runs: they contain the answers, and the assistants read open files.

### Demo 1 · T-SQL with the MSSQL extension and Copilot agent mode

Prompt: `prompts/01-tsql-agent-mode.md`. Reference answer: `sql/01-demo1-revenue-by-company.sql`.

Expected: one row per company with invoices and revenue, and a check where the four parts add up to the total.

| | CRONUS Lisboa | CRONUS Porto | CRONUS Madrid | CRONUS London | Total |
|---|---:|---:|---:|---:|---:|
| Posted invoices | n | n | n | n | n |
| Revenue excluding tax | n | n | n | n | n |

### Demo 2 · Fabric CLI

Commands: `fabric/cli-demo.md` (steps 1, 4 and 5 on stage). Prompt, to explain the import before it runs: `prompts/02-fabric-cli.md`. Expected: the workspace items listed (`bc_lab.Lakehouse`, the dataflow, `Margin.SemanticModel`), the SQL endpoint connection string, the model exported as TMDL, and a copy imported back into the workspace.

### Demo 3 · The model is a folder

Prompt: `prompts/03-measure-in-tmdl.md`. Reference: `model/snippets/03-gross-margin-measure.tmdl`.

Expected: `git diff` shows one new measure, `Gross Margin`, in `tables/salesInvoices.tmdl`, and nothing else.

### Demo 4 · A DAX user-defined function

Prompt: `prompts/04-dax-udf.md`. Reference: `model/snippets/04-gross-margin-pct-function.tmdl`.

Expected: `git diff` shows `functions.tmdl` with `GrossMarginPct` and one measure, `Gross Margin %`, that calls it. Group total: revenue n, cost n, margin n, margin % n.

### Demo 5 · Same task, two assistants

Prompt: `prompts/05-same-task-two-assistants.md`. Evidence: `sql/02-company-key-trap.sql`.

| | Revenue |
|---|---:|
| Join on the customer number only (wrong) | n |
| Join on company and number (right) | n |
| Ratio (`wrongOverRight`) | 4.00 |

With four copies of the same customers, the wrong join returns exactly four times the right total: every invoice finds its customer once in each company. Check 6 of `sql/00-row-counts-by-company.sql` confirms the premise before the session. The failure is likely in a cold window (no `AGENTS.md`), not guaranteed: if both assistants get it right, run the evidence anyway.

### Demo 6 · Guardrails

Steps: `prompts/06-pull-request.md`. The changes from demos 3 and 4 go to a branch and a pull request with `.github/pull_request_template.md`. The reviewer goes through `checklist/ai-data-code-review-checklist.md`. Only after the review is the model published to the workspace (`fab import`, see `fabric/cli-demo.md`).

## Reset to the starting state

The tag `demo-start` marks the state of this folder before the first demo.

```bash
git switch --discard-changes -C demo/live demo-start
git clean -fd -- .
```

The first line puts the branch `demo/live` back on the tag and throws away local changes. The second removes untracked files created during a rehearsal, in this folder only. Then:

1. Resume the capacity one hour before.
2. Run the Dataflow Gen2 once and check the counts of `sql/00-row-counts-by-company.sql` against the table above.
3. Re-import the starting model to the workspace if a rehearsal changed it (`fabric/cli-demo.md`, step 6).
4. Claude Code: `/clear`. Copilot Chat: new conversation.
5. At the end, pause the capacity.

Whoever runs the lab creates the tag once, when the starting state is ready: `git tag -a demo-start -m "Starting state of the demos"` and `git push origin demo-start`.

## Security

- Only CRONUS evaluation data, in a sandbox created empty. No customer names, no copies of production, nothing real on screen or in screenshots.
- No passwords, keys, tokens, client secrets or tenant IDs in this repository, in the prompts or on screen. Interactive sign-in only. Where an ID is needed, the files use placeholders such as `<tenant>`, `<environment>`, `<workspace-id>` and `<lakehouse-id>`.
- `model/Margin.SemanticModel/` points to your own workspace and lakehouse (`expressions.tmdl`). Run the demos, the branch and the pull request in a private copy of this folder. In the public repository, the model goes in only after the session, with the workspace and lakehouse IDs replaced by `<workspace-id>` and `<lakehouse-id>`, or not at all.
- Customer contact columns (`email`, `phoneNumber`, addresses) are fictitious in CRONUS, but the demos never select them: the habit matters on real data.

## Data

CRONUS is the demonstration company that ships with Dynamics 365 Business Central. Business Central data is read through the standard APIs v2.0. Official pages used to write this kit are listed in [`SOURCES.md`](SOURCES.md).

## Author

João Barros: AI & BI Consultant · Microsoft Certified Trainer (MCT) · Founder, bConcepts
