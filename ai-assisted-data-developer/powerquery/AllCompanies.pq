// AllCompanies
// Applies fnCompanyTable to every company and every entity, and combines the companies per entity.
// Result: one row per entity, with the combined table in the "data" column and its row count in "rows".
//
// Needs the query fnCompanyTable (fnCompanyTable.pq) in the same file or dataflow.
// Don't load this query itself: the four queries in entity-queries.pq reference it, and those are the
// ones that load (Power BI Desktop) or have the lakehouse as data destination (Dataflow Gen2).
// In Power BI Desktop: right-click AllCompanies, untick Enable load.

let
    // 1. The sandbox. Never a production environment.
    EnvironmentName = "lab-sessoes",

    // 2. The four demo companies, by name. A fixed list keeps the lab repeatable.
    Companies = {"CRONUS Lisboa", "CRONUS Porto", "CRONUS Madrid", "CRONUS London"},

    // 2b. Alternative: every company in the environment, read from the Navigator.
    //     This is how a model with dozens of companies stays one query: a new company appears without touching it.
    // Companies = Dynamics365BusinessCentral.ApiContentsWithOptions(null, null, null, [UseReadOnlyReplica = true]){[Name = EnvironmentName]}[Data][Name],

    // 3. The API v2.0 entities the session uses.
    Entities = {"customers", "items", "salesInvoices", "generalLedgerEntries"},

    // 4. For each entity: call the function once per company, then append the companies.
    //    Every company has the same columns, so Table.Combine lines them up by name.
    PerEntity = List.Transform(
        Entities,
        (entityName) =>
            let
                Combined = Table.Combine(List.Transform(Companies, (companyName) => fnCompanyTable(EnvironmentName, companyName, entityName)))
            in
                // The parameter is not called "entity": inside a record, [entity = entity] would point to itself.
                [entity = entityName, data = Combined, rows = Table.RowCount(Combined)]
    ),

    // 5. One row per entity.
    Result = Table.FromRecords(PerEntity, type table [entity = text, data = table, rows = Int64.Type])
in
    Result
