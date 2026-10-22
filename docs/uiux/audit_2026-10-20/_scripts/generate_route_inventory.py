import csv
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

# 1. Load PAGE_INVENTORY.csv
with open("docs/uiux/PAGE_INVENTORY.csv", encoding="utf-8") as f:
    inventory = list(csv.DictReader(f))

# 2. Load routes.dart, routes_config.dart, routes_handler.dart
with open("lib/src/app/routes/routes.dart", encoding="utf-8") as f:
    routes_dart = f.read()

route_constants = dict(re.findall(r"static const\s+(?:String\s+)?(\w+)\s*=\s*[\"']([^\"']+)[\"'];", routes_dart))

# 3. Find usage of BaseRoute.<constant> across business logic (excluding route definition files)
business_usage = {k: 0 for k in route_constants}
for root, _, files in os.walk("lib"):
    for f in files:
        if f.endswith(".dart"):
            p = os.path.join(root, f)
            if any(p.endswith(x) for x in ["routes.dart", "routes_config.dart", "routes_handler.dart"]):
                continue
            with open(p, encoding="utf-8", errors="ignore") as fl:
                content = fl.read()
            for k in route_constants:
                if f"BaseRoute.{k}" in content:
                    business_usage[k] += 1

# 4. Scan tests for screen / controller references
test_files = {}
for root, _, files in os.walk("test"):
    for f in files:
        if f.endswith(".dart"):
            p = os.path.join(root, f)
            with open(p, encoding="utf-8", errors="ignore") as tf:
                test_files[p] = tf.read()

golden_tests = [p for p, content in test_files.items() if "capture(" in content or "matchesGoldenFile" in content]

# Map specific screens explicitly covered by golden tests
explicit_golden_screens = {
    "PAGE-003", # WelcomeScreen (auth_screenshot_test.dart)
    "PAGE-004", # SignInScreen (auth_screenshot_test.dart)
    "PAGE-012", # HomeScreen / Navigation (home_screenshot_test.dart)
    "PAGE-013", # WalletsScreen (wallets_screenshot_test.dart)
    "PAGE-020", # TransferScreen (transfer_screenshot_test.dart - TransferReviewStepSection & TransferSuccessStepSection)
    "PAGE-023", # ExchangeScreen (exchange_screenshot_test.dart - ExchangeAmountStepSection, ExchangeSwapReviewStepSection, ExchangeSuccessStepSection)
}

verified_rows = []

for row in inventory:
    rid = row["id"]
    rc_name = row["route_constant"].replace("BaseRoute.", "")
    rp = row["route_path"]
    domain = row["domain"]
    priority = row["priority"]
    sf = row["screen_file"]
    cf = row["controller_file"]
    orig_notes = row.get("notes", "")

    # Check screen file existence
    exists_screen = "TRUE" if (sf != "none" and os.path.isfile(sf)) else "FALSE"

    # Check controller existence
    if cf == "none":
        exists_controller = "N/A"
    else:
        ctrl_paths = [p.strip() for p in cf.split(";")]
        all_exist = all(os.path.isfile(p) for p in ctrl_paths)
        exists_controller = "TRUE" if all_exist else "FALSE"

    # Check widget test & golden test
    has_golden = "TRUE" if rid in explicit_golden_screens else "FALSE"

    # Screen class names
    sclasses = []
    if os.path.isfile(sf):
        with open(sf, encoding="utf-8", errors="ignore") as fl:
            sclasses = re.findall(r"class\s+([A-Z]\w+)\s+extends", fl.read())
    sbase = os.path.basename(sf).replace(".dart", "")

    matched_tests = []
    has_widget = False
    for tp, tcontent in test_files.items():
        tname = os.path.basename(tp)
        matched = False
        if sbase in tcontent:
            matched = True
        for sc in sclasses:
            if sc in tcontent:
                matched = True
        if matched:
            matched_tests.append(tname)
            if "testWidgets" in tcontent or "pumpWidget" in tcontent or "pumpScreen" in tcontent:
                has_widget = True

    if rid in explicit_golden_screens:
        has_widget = True

    has_widget_test = "TRUE" if has_widget else "FALSE"

    # Determine notes & flags
    notes_parts = []
    if orig_notes:
        notes_parts.append(orig_notes)

    usage = business_usage.get(rc_name, 0)
    if usage == 0:
        notes_parts.append("UNUSED CONSTANT in app logic (bypassed via direct Get.to or dead link)")
    else:
        notes_parts.append(f"Referenced {usage}x in app logic")

    if matched_tests:
        notes_parts.append(f"Tested in: {', '.join(matched_tests[:2])}")
    else:
        notes_parts.append("No direct test file")

    note_text = " | ".join(notes_parts)

    verified_rows.append({
        "id": rid,
        "route_constant": row["route_constant"],
        "route_path": rp,
        "domain": domain,
        "priority": priority,
        "screen_file": sf,
        "controller_file": cf,
        "exists_screen": exists_screen,
        "exists_controller": exists_controller,
        "has_widget_test": has_widget_test,
        "has_golden_test": has_golden,
        "notes": note_text
    })

fieldnames = [
    "id",
    "route_constant",
    "route_path",
    "domain",
    "priority",
    "screen_file",
    "controller_file",
    "exists_screen",
    "exists_controller",
    "has_widget_test",
    "has_golden_test",
    "notes"
]

out_path = "docs/uiux/audit_2026-10-20/ROUTE_INVENTORY_VERIFIED.csv"
with open(out_path, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=fieldnames)
    w.writeheader()
    w.writerows(verified_rows)

print(f"Successfully generated {len(verified_rows)} rows in {out_path}")
