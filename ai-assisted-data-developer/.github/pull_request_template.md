## What changes

<!-- One or two sentences. Which files, which objects (query, measure, function, table). -->

## Why

<!-- The business request, in the requester's words. -->

## How it was written

- Assistant: <!-- GitHub Copilot / Claude Code / none -->
- Prompt: <!-- paste it, or link the file in prompts/ -->
- What I changed by hand after the assistant:

## Evidence

<!-- The numbers that prove it, from the source, per company. Not from the new code's own result. -->

| Company | Source total | After the change | Difference |
|---|---:|---:|---:|
| CRONUS Lisboa | | | |
| CRONUS Porto | | | |
| CRONUS Madrid | | | |
| CRONUS London | | | |
| All companies | | | |

Query or file used for the check:

## Review checklist

The full text is in `checklist/ai-data-code-review-checklist.md`.

- [ ] 1. Grain: one row means what I think at every step
- [ ] 2. Joins: the company is in every join, and no join multiplies rows
- [ ] 3. NULLs: blanks and missing keys handled
- [ ] 4. Definitions: revenue, cost, dates and currency match `AGENTS.md`
- [ ] 5. Filters and dates: boundaries and status values checked
- [ ] 6. Totals reconcile, per company, against the source
- [ ] 7. Edge cases tested
- [ ] 8. Every name and every piece of syntax exists in our version
- [ ] 9. No data changes, no `SELECT *`, no contact columns, no secrets or IDs
- [ ] 10. I can explain it in two sentences

## Deployment

- [ ] Reviewed by someone other than the author
- [ ] Published to the workspace only after approval (`fab import` or Git integration), never from a local copy
