"""Fan-out trap: total revenue per customer, including tax and freight.

Plausible version: join order headers to order lines, then sum TotalDue.
TotalDue lives on the header, so after the join it is repeated on every line and the sum is inflated.

Evidence that catches it:
  1. Grain check: is SalesOrderID unique in the frame you are summing a header column from?
  2. Reconciliation: does the sum of the parts equal the source total?
"""

from pathlib import Path

import pandas as pd

DATA = Path(__file__).parent / "data"

headers = pd.read_csv(DATA / "SalesOrderHeader.csv")
lines = pd.read_csv(DATA / "SalesOrderDetail.csv")

source_total = headers["TotalDue"].sum()

# Plausible version: header joined to lines, header amount summed after the join
merged = headers.merge(lines, on="SalesOrderID", how="inner")
plausible = merged.groupby("CustomerID", as_index=False)["TotalDue"].sum()

# Order grain first: TotalDue is summed where it lives
correct = headers.groupby("CustomerID", as_index=False)["TotalDue"].sum()

print(f"Rows       headers={len(headers):,}  lines={len(lines):,}  after join={len(merged):,}")
print(f"Source     TotalDue = {source_total:,.2f}")
print(f"Plausible  TotalDue = {plausible['TotalDue'].sum():,.2f}")
print(f"Correct    TotalDue = {correct['TotalDue'].sum():,.2f}")

# Check 1: grain. TotalDue is a header value, so each order must appear once in the frame we sum it from.
print(f"Order unique after join? {merged['SalesOrderID'].is_unique}")

# Check 2: reconciliation against the source table
gap = plausible["TotalDue"].sum() - source_total
if abs(gap) > 0.01:
    print(f"Fan-out: the joined version overstates revenue by {gap:,.2f}")

assert abs(correct["TotalDue"].sum() - source_total) < 0.01, "correct version does not reconcile"
print("Correct version reconciles with the source.")
