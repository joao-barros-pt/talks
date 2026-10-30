# From Business Central to OneLake, and a Direct Lake model on top

Step by step, from an empty `LAB Sessoes` workspace to the `Margin` semantic model in Direct Lake over the `bc_lab` lakehouse. Admin steps (capacity, tenant settings, XMLA) are for whoever runs the lab.

## Before you start

- Workspace `LAB Sessoes` on a Fabric capacity (F2 or a trial), resumed.
- Lakehouse `bc_lab` in that workspace.
- Business Central sandbox `lab-sessoes` with the four CRONUS companies.
- The four files in `powerquery/`.

## 1. Dataflow Gen2: the same queries, landed once

1. In `LAB Sessoes`: **New item**, **Dataflow Gen2**. Name: `df_bc_lab`.
2. **Get data**, **Blank query**. Paste `powerquery/fnCompanyTable.pq` and rename the query to `fnCompanyTable`.
3. The first time the connector runs, **Configure connection**: Dynamics 365 Business Central, organizational account (Microsoft Entra ID), sign in. No keys or secrets: interactive sign-in only.
4. **Blank query** again: paste `powerquery/AllCompanies.pq`, rename to `AllCompanies`.
5. One **Blank query** per block in `powerquery/entity-queries.pq`: `customers`, `items`, `salesInvoices`, `generalLedgerEntries` and `RowsPerCompany`.
6. Look at `RowsPerCompany` first: four companies per entity, and no company with zero rows. This is the evidence before anything lands.
7. For each of the four entity queries: **Add data destination** (ribbon, or **Data destination** in the query settings), **Lakehouse**, then in the navigator `LAB Sessoes` and `bc_lab`.
   - **New table**, with the same name as the query.
   - Update method **Replace**: every refresh drops the data and writes it again.
   - Check the column mapping. Currency columns become decimal. Any column still typed as *any* needs a type before the destination.
8. `fnCompanyTable`, `AllCompanies` and `RowsPerCompany` get no destination. If **Enable staging** is ticked on any of them, untick it: `AllCompanies` holds nested tables, which can't be staged.
9. **Save** (or **Save and run**). Watch the run in the refresh history of the dataflow.
10. In the lakehouse, **Tables** shows `customers`, `items`, `salesInvoices` and `generalLedgerEntries`, each with the `company` column.
11. Connect the MSSQL extension to the SQL analytics endpoint and run `sql/00-row-counts-by-company.sql`. The counts must match `RowsPerCompany`.

Notes:

- In Fabric, the Business Central connector is used through Power Query Online, which is what Dataflow Gen2 runs on.
- Lakehouse destinations write directly, without staging, by default.
- If the table name has characters the lakehouse doesn't accept, the destination adjusts it. The four names above are plain on purpose.
- New in 2026: Business Central can mirror tables and companies into OneLake without calling the APIs. Not part of these demos; whether it works in your sandbox: to be confirmed in the lab.

## 2. The Direct Lake model

### Create it (Power BI Desktop)

1. Power BI Desktop, **OneLake catalog**, choose the lakehouse `bc_lab`, **Connect**.
2. Name: `Margin`. Workspace: `LAB Sessoes`. Tables: the four. **OK**.
3. The model is created in the workspace and Power BI Desktop is now **live editing** it. Changes go straight to the workspace.

Requirements for live editing: XMLA endpoints allowed in the tenant settings, XMLA **Read Write** on the capacity, Write permission on the model and at least Viewer on the lakehouse. A free license can't do it.

Alternative: open the lakehouse in the browser and choose **New semantic model**.

### Relationships

Direct Lake relationships need matching data types, and the one side must be unique. A calculated column can't be a relationship key in Direct Lake, which is why the keys come from Power Query.

| From (many) | To (one) | Cardinality |
|---|---|---|
| `salesInvoices[customerKey]` | `customers[customerKey]` | many to one, single direction |
| `generalLedgerEntries[invoiceKey]` | `salesInvoices[invoiceKey]` | many to one, single direction |

A filter on a customer (or on `customers[company]`) then reaches the invoices and, through them, the G/L entries. `sql/00-row-counts-by-company.sql` checks that both one sides are unique.

### Starting measures

In **TMDL view**, paste `model/snippets/00-starting-measures.tmdl`, fill the cost of goods sold accounts, and **Apply**. That gives `Revenue` and `Cost`, the state the demos start from.

### Save it as code

1. **File**, **Export**, **Power BI Project (PBIP)**, into `model/` in this folder. The model definition lands in `model/Margin.SemanticModel/definition/` as TMDL files.
2. Before committing: open `definition/expressions.tmdl` and any `.platform` file and replace workspace and lakehouse IDs with `<workspace-id>` and `<lakehouse-id>` if the folder goes public.
3. Commit, and tag the starting state: `git tag -a demo-start -m "Starting state of the demos"`.

### Publish changes back

A Power BI Project of a Direct Lake model can't be published from Power BI Desktop. Two ways:

- **Fabric CLI** (`fab import`), after the pull request is reviewed: `cli-demo.md`, step 6.
- **Fabric Git integration**: the workspace syncs with a branch. If you use it, connect the lab workspace to a private repository or to a `lab` branch, never to `main` of a public repository.

## If it goes wrong

| Problem | What to do |
|---|---|
| The connector asks for a key or a secret | Wrong authentication kind. Use the organizational account. |
| `Formula.Firewall` in Power BI Desktop | All queries read the same source. In the lab file: Options, Privacy, set both sources to Organizational, or ignore privacy levels for this file only. |
| An entity fails with "Can't insert a record. Current connection intent is Read-Only" | A custom API writes while reading. Not expected with the standard APIs v2.0; set `UseReadOnlyReplica = false` only for that call. |
| A column type is rejected by the destination | Give it an explicit type in the entity query (decimal for amounts, date for dates, text for codes). |
| A query fails with "duplicate values" on a relationship | The one side is not unique. Run the uniqueness checks in `sql/00-row-counts-by-company.sql`: the key is missing the company. |
| A company returns zero rows | Check the exact company name in the Business Central Navigator (spaces, capitals). |
