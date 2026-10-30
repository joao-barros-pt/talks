// entity-queries.pq
// Five small queries. Create each one as a Blank query with the name in its header and paste its code.
// The first four load: in Dataflow Gen2 each one gets the lakehouse bc_lab as data destination,
// new table, same name as the query, update method Replace.
// The fifth, RowsPerCompany, is the evidence: don't load it, just look at it before you trust the totals.
//
// The key columns (customerKey, invoiceKey) are built here, not in the model: a Direct Lake model can't
// use a calculated column in a relationship, so the composite key has to exist in the lakehouse.


// ===== Query: customers =====================================================================
let
    // 1. All companies, one row per customer per company.
    Source = AllCompanies{[entity = "customers"]}[data],

    // 2. Model key: company and number. Customer 10000 exists in every company.
    WithKey = Table.AddColumn(Source, "customerKey", each [company] & "|" & [number], type text)
in
    WithKey


// ===== Query: items =========================================================================
let
    // One row per item per company. No key column: the session doesn't relate items to anything.
    Source = AllCompanies{[entity = "items"]}[data]
in
    Source


// ===== Query: salesInvoices =================================================================
let
    // 1. All companies, one row per sales invoice header per company. Drafts included: see status.
    Source = AllCompanies{[entity = "salesInvoices"]}[data],

    // 2. Key to the customer: company and customerNumber. A draft can have no customer yet.
    WithCustomerKey = Table.AddColumn(
        Source,
        "customerKey",
        each if [customerNumber] = null or [customerNumber] = "" then null else [company] & "|" & [customerNumber],
        type nullable text
    ),

    // 3. Key of the invoice itself: company and number. The G/L entries point to it through documentNumber.
    WithInvoiceKey = Table.AddColumn(WithCustomerKey, "invoiceKey", each [company] & "|" & [number], type text)
in
    WithInvoiceKey


// ===== Query: generalLedgerEntries ==========================================================
let
    // 1. All companies, one row per G/L entry per company.
    Source = AllCompanies{[entity = "generalLedgerEntries"]}[data],

    // 2. Key to the invoice: company and documentNumber. Entries without a document number get no key.
    WithInvoiceKey = Table.AddColumn(
        Source,
        "invoiceKey",
        each if [documentNumber] = null or [documentNumber] = "" then null else [company] & "|" & [documentNumber],
        type nullable text
    )
in
    WithInvoiceKey


// ===== Query: RowsPerCompany (evidence, don't load) =========================================
let
    // 1. Rows per company and entity, read from the combined tables.
    Source = AllCompanies,
    PerCompany = Table.AddColumn(
        Source,
        "perCompany",
        each Table.Group([data], {"company"}, {{"rows", Table.RowCount, Int64.Type}}),
        type table [company = text, rows = Int64.Type]
    ),

    // 2. One row per entity and company. Compare with sql/00-row-counts-by-company.sql after the load.
    Result = Table.ExpandTableColumn(Table.SelectColumns(PerCompany, {"entity", "perCompany"}), "perCompany", {"company", "rows"})
in
    Result
