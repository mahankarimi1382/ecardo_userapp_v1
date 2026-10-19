import csv
import json

matrix_path = r"C:\Users\talas\OneDrive\Desktop\ecardo\docs\uiux_upgrade_pack_20261019\ecardo_uiux_upgrade_pack\03_PAGE_INVENTORY_AND_AUDIT_MATRIX.csv"

with open(matrix_path, "r", encoding="utf-8-sig") as f:
    reader = list(csv.DictReader(f))

for i, row in enumerate(reader, 1):
    print(f"Row {i:02d}: [{row['domain']}] {row['page_family']} (Priority: {row['priority']})")
    print(f"    Focus: {row['acceptance_focus']}")
