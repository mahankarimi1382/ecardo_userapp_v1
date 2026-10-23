import csv

with open("docs/app-map/ROUTE_CATALOG.csv", "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    domains = {}
    for r in reader:
        d = r.get("module_id", "OTHER")
        s = r.get("upgrade_status", "UNKNOWN")
        if d not in domains:
            domains[d] = {"total": 0, "upgraded": 0}
        domains[d]["total"] += 1
        if s in ("UPGRADED", "COMPLETE"):
            domains[d]["upgraded"] += 1

print("=== DOMAIN UPGRADE STATUS ===")
for d, c in sorted(domains.items()):
    upg, tot = c["upgraded"], c["total"]
    pct = (upg / tot) * 100 if tot > 0 else 0
    print(f"{d:<16}: {upg:3d} / {tot:3d} ({pct:5.1f}%)")
