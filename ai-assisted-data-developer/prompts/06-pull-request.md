# Demo 6: a pull request before the workspace

**Tools:** Git, GitHub, Claude Code or Copilot for the description
**Template:** `.github/pull_request_template.md`
**Checklist:** `checklist/ai-data-code-review-checklist.md`

The changes of demos 3 and 4 are on the branch `demo/live`. Nothing has reached the workspace yet. `origin` is the private copy of this folder, not the public `talks` repository: the model holds your workspace and lakehouse IDs (README, Security).

## Steps

```bash
git status
git add model/Margin.SemanticModel
git commit -m "Gross Margin and Gross Margin % with GrossMarginPct"
git push -u origin demo/live
```

Then open the pull request on GitHub from `demo/live` to `main`. GitHub fills the description with the template.

## The prompt (optional, for the description)

```text
Fill in the pull request template in .github/pull_request_template.md for the changes on this branch
against main. Use git diff. Leave the Evidence table empty: I fill it in from the reconciliation queries.
Don't tick any checklist box.
```

## What to point at

- The reviewer reads the diff from demos 3 and 4, not a screenshot of a report.
- The evidence table is filled from `sql/02-company-key-trap.sql` and `model/snippets/05-evidence-query.dax`, by a person.
- The assistant wrote the description and left the boxes alone. Ticking them is the reviewer's job.
- Only after approval does the model go to the workspace: `fabric/cli-demo.md`, step 6.
- In a real team: protect `main` so a pull request needs a review that is not the author's.

## After the session

Close the pull request without merging, or merge it into a lab branch: `main` keeps the starting state, and `demo-start` stays where it is.
