# Schema card: AdventureWorksLT (schema `SalesLT`)

Only the tables the demos need. Personal data columns are left out on purpose.
Regenerate the columns, keys and sample rows with `context/build-schema-card.sql` if your copy differs.

## Tables and grain

**SalesLT.SalesOrderHeader**: one row per sales order
SalesOrderID int (PK), OrderDate datetime, DueDate datetime, ShipDate datetime NULL, Status tinyint, OnlineOrderFlag bit, SalesOrderNumber nvarchar, CustomerID int (FK Customer), ShipMethod nvarchar, SubTotal money, TaxAmt money, Freight money, TotalDue money (computed: SubTotal + TaxAmt + Freight)

**SalesLT.SalesOrderDetail**: one row per order line
SalesOrderID int (PK, FK SalesOrderHeader), SalesOrderDetailID int (PK), OrderQty smallint, ProductID int (FK Product), UnitPrice money, UnitPriceDiscount money, LineTotal numeric (computed: UnitPrice x (1 - UnitPriceDiscount) x OrderQty)

**SalesLT.Product**: one row per product
ProductID int (PK), Name nvarchar, ProductNumber nvarchar, Color nvarchar NULL, StandardCost money, ListPrice money, Size nvarchar NULL, ProductCategoryID int NULL (FK ProductCategory), SellStartDate datetime, SellEndDate datetime NULL

**SalesLT.ProductCategory**: one row per category, two levels
ProductCategoryID int (PK), ParentProductCategoryID int NULL (FK ProductCategory, NULL = top level), Name nvarchar

**SalesLT.Customer**: one row per customer
CustomerID int (PK), FirstName nvarchar, LastName nvarchar, CompanyName nvarchar NULL, SalesPerson nvarchar NULL
Left out on purpose: EmailAddress, Phone, PasswordHash, PasswordSalt

## Relationships

- SalesOrderDetail.SalesOrderID -> SalesOrderHeader.SalesOrderID (many lines per order)
- SalesOrderDetail.ProductID -> Product.ProductID
- SalesOrderHeader.CustomerID -> Customer.CustomerID (many orders per customer; not every customer has orders)
- Product.ProductCategoryID -> ProductCategory.ProductCategoryID (products usually sit on the second level)
- ProductCategory.ParentProductCategoryID -> ProductCategory.ProductCategoryID

## Business definitions

- Revenue, product view = SUM(SalesOrderDetail.LineTotal)
- Order value, customer view = SalesOrderHeader.SubTotal (TotalDue only when "including tax and freight" is asked)
- Average order value = total order value / number of distinct orders

## Data notes

From `sql/00-sanity-checks.sql`:

- Orders: 32, all dated 2008-06-01. Each ordering customer has exactly one order.
- Order lines: 542, about 17 per order.
- Customers with at least one order: 32 of 847.
- Products with NULL Color: 50 of 295. Red products: 38.
- Categories: 4 top level, 37 second level. Every product has a category.
- SubTotal is not the sum of the order lines in this sample: 865,433.12 against 708,690.15. Use the definition that matches the question.

## Sample rows

Three rows per table, from section 4 of `context/build-schema-card.sql`:

- SalesOrderHeader: `[{"SalesOrderID":71774,"OrderDate":"2008-06-01T00:00:00","CustomerID":29847,"SubTotal":880.3484,"TaxAmt":70.4279,"Freight":22.0087,"TotalDue":972.7850},{"SalesOrderID":71776,"OrderDate":"2008-06-01T00:00:00","CustomerID":30072,"SubTotal":78.8100,"TaxAmt":6.3048,"Freight":1.9703,"TotalDue":87.0851},{"SalesOrderID":71780,"OrderDate":"2008-06-01T00:00:00","CustomerID":30113,"SubTotal":38418.6895,"TaxAmt":3073.4952,"Freight":960.4672,"TotalDue":42452.6519}]`
- SalesOrderDetail: `[{"SalesOrderID":71774,"SalesOrderDetailID":110562,"OrderQty":1,"ProductID":836,"UnitPrice":356.8980,"UnitPriceDiscount":0.0000,"LineTotal":356.898000},{"SalesOrderID":71774,"SalesOrderDetailID":110563,"OrderQty":1,"ProductID":822,"UnitPrice":356.8980,"UnitPriceDiscount":0.0000,"LineTotal":356.898000},{"SalesOrderID":71776,"SalesOrderDetailID":110567,"OrderQty":1,"ProductID":907,"UnitPrice":63.9000,"UnitPriceDiscount":0.0000,"LineTotal":63.900000}]`
- Product: `[{"ProductID":680,"Name":"HL Road Frame - Black, 58","Color":"Black","ListPrice":1431.5000,"ProductCategoryID":18},{"ProductID":706,"Name":"HL Road Frame - Red, 58","Color":"Red","ListPrice":1431.5000,"ProductCategoryID":18},{"ProductID":707,"Name":"Sport-100 Helmet, Red","Color":"Red","ListPrice":34.9900,"ProductCategoryID":35}]`
- ProductCategory: `[{"ProductCategoryID":1,"ParentProductCategoryID":null,"Name":"Bikes"},{"ProductCategoryID":2,"ParentProductCategoryID":null,"Name":"Components"},{"ProductCategoryID":3,"ParentProductCategoryID":null,"Name":"Clothing"}]`
