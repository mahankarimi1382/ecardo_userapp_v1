import sys
import csv

sys.stdout.reconfigure(encoding='utf-8')

matrix_path = r"C:\Users\talas\OneDrive\Desktop\ecardo\docs\uiux_upgrade_pack_20261019\ecardo_uiux_upgrade_pack\03_PAGE_INVENTORY_AND_AUDIT_MATRIX.csv"

with open(matrix_path, "r", encoding="utf-8") as f:
    reader = csv.reader(f)
    for i, row in enumerate(reader):
        print(f"Row {i:02d}: {row}")
