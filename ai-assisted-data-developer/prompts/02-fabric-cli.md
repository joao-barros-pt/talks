# Demo 2: the Fabric CLI, explained before it runs

**Tool:** GitHub Copilot Chat or Claude Code, this folder open, with a terminal
**Commands:** `fabric/cli-demo.md`, steps 1, 4 and 5
**Evidence:** `fab ls "LAB Sessoes.Workspace" -l` before and after the import

The commands are typed from `fabric/cli-demo.md`, not generated live. The assistant's job here is to explain a command before it runs, so you read the flags out loud.

## Before you start

- Signed in already: `fab auth status` shows the lab account. Interactive sign-in only.
- Terminal font at stage size. No tenant or workspace IDs on screen.
- Never `fab ls` without a path: always start from `"LAB Sessoes.Workspace"`.

## The prompt

Before step 5 of `fabric/cli-demo.md`:

```text
Explain this Fabric CLI command before I run it. What does each flag do, what will it create or overwrite,
and is there anything I should check first? Don't run it.

fab import "LAB Sessoes.Workspace/Margin CLI.SemanticModel" -i ./fabric/export/Margin.SemanticModel -f
```

## What should come back

- `import` creates or overwrites an item from a local definition. The path is `<workspace>.Workspace/<item>.<ItemType>`.
- `-i` is the local folder with the definition (here, the TMDL that `fab export` wrote in step 4).
- `-f` skips the confirmation prompt: if `Margin CLI` already exists, it is overwritten without asking.
- A suggestion to check first with `fab ls`, or to drop `-f` outside a demo.

## What to point at

- Everything you click in the portal you can now type, review and repeat. Whatever you can type, an assistant can draft, and you review before it runs.
- `-f` is fine on stage. In real work, read the prompt it skips.
- The copy is called `Margin CLI` on purpose: the real `Margin` model is published only after the pull request (demo 6, `fabric/cli-demo.md`, step 6).

## If it goes wrong

- It invents a flag: check it against `fab import --help` or the command table in `fabric/cli-demo.md`. A plausible flag that doesn't exist is check 8 of the review checklist.
- It runs the command instead of explaining it: say so, and point at "Don't run it."
- The import fails: show the export (step 4) and the plan B slide.
