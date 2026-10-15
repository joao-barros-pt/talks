# Data prompt template (SCOPE)

Copy it, fill in the brackets, delete what doesn't apply. Works the same for T-SQL, DAX and Python.

---

**Goal**
I need [the result] for [who will use it, what decision]. Give me [a query | a measure | a function] in [T-SQL for SQL Server 2022 | DAX | Python 3.12 with pandas].

**S: Schema and grain**
Use only these tables and columns:
- [schema.table]: [columns]. One row per [order | order line | customer | day].
- [schema.table]: [columns]. One row per [...].

Relationships: [a.key -> b.key, one-to-many].
Sample rows, three per table, no personal data: [paste].

**C: Constraints**
- Definitions: [revenue = ...]; [order value = ...]; [active customer = ...].
- Filters and period: [...]. A NULL in [column] means [...].
- Rules: [no SELECT *]; [no new tables or views]; [must run in under N seconds on N rows].
- Output: assumptions first, as a short list, then the code.

**O: Open questions first**
Before writing any code, ask me up to three questions about anything ambiguous. Don't guess the grain or a business definition.

**P: Patch, don't restart** (for the follow-up turns)
Keep everything that already works. Change only [...]. Show me the lines you changed.

**E: Evidence**
Together with the code, give me:
- a reconciliation check (the parts add up to the source total), and
- one edge case to test (NULLs, an empty period, duplicates, a zero denominator).

---

Why each part is there:

- **Schema and grain** stop the assistant from inventing table names and from aggregating at the wrong level.
- **Constraints** turn your business vocabulary into something it can't misread.
- **Open questions** surface the ambiguity before it becomes code.
- **Patch** keeps the context you already paid for in the conversation.
- **Evidence** is the part you can't delegate.
