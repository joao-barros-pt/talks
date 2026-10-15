# Data for the pandas demo

Two CSV files from AdventureWorksLT, already here:

- `SalesOrderHeader.csv` (32 orders): `SELECT SalesOrderID, OrderDate, CustomerID, SubTotal, TaxAmt, Freight, TotalDue FROM SalesLT.SalesOrderHeader;`
- `SalesOrderDetail.csv` (542 order lines): `SELECT SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal FROM SalesLT.SalesOrderDetail;`

They match the database that `setup/00-create-adventureworkslt.sql` creates. To export them yourself, run each query in VS Code with the MSSQL extension and use the results grid's **Save as CSV** option, keeping the column names in the header row.

Expected output of `python python/fan_out_trap.py`:

```text
Rows       headers=32  lines=542  after join=542
Source     TotalDue = 956,303.59
Plausible  TotalDue = 35,854,355.90
Correct    TotalDue = 956,303.59
Order unique after join? False
Fan-out: the joined version overstates revenue by 34,898,052.31
Correct version reconciles with the source.
```
