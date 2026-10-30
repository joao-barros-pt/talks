# Demo 2: the Fabric CLI

The workspace from the terminal: list it, read the SQL endpoint, export the model as text and publish it back. Package `ms-fabric-cli`, command `fab`. Command-line mode: every line starts with `fab`. Names with spaces go in double quotes, in PowerShell and in bash.

Paths follow the pattern `<workspace>.Workspace/<item>.<ItemType>`, for example `"LAB Sessoes.Workspace/bc_lab.Lakehouse"`.

## Before the session

```bash
pip install --upgrade ms-fabric-cli
fab --version
fab auth login        # choose "Interactive with a web browser"
fab auth status
```

- Sign in with the account that owns the lab. Interactive sign-in only: no service principal, no secret on screen or in a file.
- Don't run `fab ls` without a path on screen: it lists every workspace your account can see, including ones that have nothing to do with the lab. Always start from `"LAB Sessoes.Workspace"`.
- Run every command below once before the session. The first call of each kind can be slow.

## The demo

Terminal open in this folder (`ai-assisted-data-developer`).

### 1. What is in the workspace

```bash
fab ls "LAB Sessoes.Workspace" -l
```

Expected: `bc_lab.Lakehouse`, `df_bc_lab.Dataflow` and `Margin.SemanticModel`, and the lakehouse's `bc_lab.SQLEndpoint` (whether it shows without `-a`: to be confirmed in the lab).

### 2. What is in the lakehouse

```bash
fab ls "LAB Sessoes.Workspace/bc_lab.Lakehouse/Tables"
```

Expected: `customers`, `items`, `salesInvoices`, `generalLedgerEntries`. If the lakehouse has schemas, the tables are one level down, under `dbo` (to be confirmed in the lab).

### 3. The SQL endpoint, for demo 1

```bash
fab get "LAB Sessoes.Workspace/bc_lab.Lakehouse" -q properties.sqlEndpointProperties
```

The result has the connection string the MSSQL extension needs. It also shows IDs: fine on screen for a demo workspace, never pasted into the repository.

### 4. The model as text

```bash
fab export "LAB Sessoes.Workspace/Margin.SemanticModel" -o ./fabric/export --format TMDL -f
```

Creates `fabric/export/Margin.SemanticModel/` with the TMDL files. `fabric/export/` is in `.gitignore`: it can contain IDs. Open `definition/tables/salesInvoices.tmdl` for ten seconds: the same model as in `model/`, straight from the workspace.

### 5. Publish a copy

```bash
fab import "LAB Sessoes.Workspace/Margin CLI.SemanticModel" -i ./fabric/export/Margin.SemanticModel -f
fab ls "LAB Sessoes.Workspace" -l
```

A second model, `Margin CLI`, appears in the workspace. Same definition, published from the terminal.

### 6. Publish the reviewed model (end of demo 6)

Only after the pull request is reviewed, from the branch that holds the reviewed TMDL:

```bash
fab import "LAB Sessoes.Workspace/Margin.SemanticModel" -i ./model/Margin.SemanticModel -f
fab open "LAB Sessoes.Workspace/Margin.SemanticModel"
```

Overwrites the model in the workspace with the definition from Git and opens it in the browser. That the PBIP folder exported from Power BI Desktop imports as is: to be confirmed in the lab. If it doesn't, export the starting model with step 4, copy the changed `.tmdl` files into that folder and import it.

### 7. Clean up after a rehearsal

```bash
fab rm "LAB Sessoes.Workspace/Margin CLI.SemanticModel" -f
```

## Commands used

| Command | What it does |
|---|---|
| `fab auth login` / `fab auth status` | Sign in, check who is signed in |
| `fab ls <path> [-l]` | List workspaces, items, or files and tables inside an item |
| `fab get <path> [-q <query>]` | Read an item's properties, filtered with a JMESPath query |
| `fab export <path> -o <folder> [--format TMDL] [-f]` | Write an item definition to a local folder. Semantic models take `TMDL` or `TMSL` |
| `fab import <path> -i <folder> [-f]` | Create or overwrite an item from a local definition |
| `fab open <path>` | Open the item in the Fabric portal |
| `fab rm <path> [-f]` | Delete an item |

`-f` skips the confirmation prompt. On stage that keeps the demo moving; in real work, read the prompt.

## If it goes wrong

| Problem | What to do |
|---|---|
| `fab` not found | `python -m pip install ms-fabric-cli`, then open a new terminal. |
| Not authenticated | `fab auth login` again, interactive with a web browser. |
| Path not found | Check the item type in the path (`.Lakehouse`, `.SemanticModel`) and the quotes around names with spaces. |
| `fab import` of the Direct Lake model fails | Plan B: show the export (step 4) and the copy already published in a rehearsal. Publishing goes through Fabric Git integration instead. |
