# Talks

Demos, scripts, prompts and templates from my community sessions on data and AI: SQL Server, Power BI, Microsoft Fabric, and AI assistants such as GitHub Copilot and Claude.

João Barros · AI & BI Consultant · Microsoft Certified Trainer (MCT) · Founder, bConcepts · [LinkedIn](https://www.linkedin.com/in/joaoluisbarros/)

## Sessions

| Session | Where and when | What you get |
|---|---|---|
| [Prompting for Data People: Getting Real Work Out of Copilot and Claude](prompting-for-data-people/) | Cloud Data Driven User Group, online, 15 October 2026 | The SCOPE method, the demo database in one script, the exact demo prompts, a reusable prompt template and a review checklist for AI-generated code |
| [The AI-Assisted Data Developer](ai-assisted-data-developer/) | SQL Server User Group Croatia, online, 12 November 2026 · AI Virtual Days, online, 14 November 2026 · Dynamics 365 AI ERP Summit, Lisbon, 27 November 2026 · Microsoft Fabric User Group Pune, online, 29 November 2026 | The lab kit for Business Central data in Fabric (one Power Query function for N companies, Dataflow Gen2, Direct Lake), the T-SQL, Fabric CLI, TMDL and DAX user-defined function demos, the company key trap with its reconciliation, the exact prompts, a pull request template and the review checklist, ERP edition |
| [DAX User-Defined Functions: Write Once, Reuse Everywhere](dax-user-defined-functions/) | Power BI & Fabric Barcelona user group, Barcelona, 19 November 2026 | One DAX query per demo for DAX query view, the same functions in TMDL with a createOrReplace script, the project context for AI assistants and the sources behind every claim |

## How to use this repository

Each session has its own folder, and each folder has a README with what the session covers, how to set up the demos and what results to expect.

- Clone everything: `git clone https://github.com/joao-barros-pt/talks.git`
- Or download a single session folder from its page on GitHub.
- Open the session folder itself in VS Code (File, Open Folder), not the whole repository: instruction files such as `AGENTS.md` and `.github/copilot-instructions.md` apply to the folder you open.

## License

Code and text are under the MIT License (see [LICENSE](LICENSE)). The sample databases belong to Microsoft and are published under the MIT License in [microsoft/sql-server-samples](https://github.com/microsoft/sql-server-samples) and [microsoft/powerbi-desktop-samples](https://github.com/microsoft/powerbi-desktop-samples).
