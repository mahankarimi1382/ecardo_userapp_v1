import json
import csv
import os
import re

base_dir = os.path.abspath(".")
output_page_inventory = os.path.join(base_dir, "docs", "uiux", "PAGE_INVENTORY.csv")

with open("tools/routes_classified.json", "r", encoding="utf-8") as f:
    routes = json.load(f)

# Re-filter controllers to ensure only *Controller files
for r in routes:
    clean_ctrls = []
    for cf in r['controller_files']:
        # If it's a Service, skip
        if "service" in cf.lower() and not "controller" in cf.lower():
            continue
        if cf.endswith("_controller.dart") or "controller" in cf.lower():
            if os.path.exists(cf):
                clean_ctrls.append(cf)
    
    # Specific known inline / missing
    if r['route_constant'] == "BaseRoute.replayTicket":
        clean_ctrls = ["lib/src/presentation/screens/settings/controller/reply_ticket_controller.dart"]
    elif r['route_constant'] == "BaseRoute.appUpdate":
        clean_ctrls = ["lib/src/common/services/app_update_controller.dart"]
        
    r['clean_ctrl_files'] = list(dict.fromkeys(clean_ctrls))

# Generate PAGE_INVENTORY.csv
page_rows = []
for i, r in enumerate(routes, 1):
    pid = f"PAGE-{i:03d}"
    domain = r['domain']
    r_const = r['route_constant']
    r_path = r['route_path']
    screen_f = r['screen_file']
    
    ctrl_str = ";".join(r['clean_ctrl_files']) if r['clean_ctrl_files'] else "none"
    
    # Clean binding files
    b_files = []
    for bf in r['binding_files']:
        if not bf.startswith("UNKNOWN") and os.path.exists(bf):
            b_files.append(bf)
    b_str = ";".join(dict.fromkeys(b_files)) if b_files else "none"
    
    priority = r['priority']
    notes = r['notes']
    if r_const == "BaseRoute.replayTicket":
        notes += " (Controller registered inline via Get.put)"
    elif r_const == "BaseRoute.navigation":
        notes += " (Bottom navigation shell registering 8 bindings)"
    elif r_const == "BaseRoute.localeTransition":
        notes += " (Language switch waypoint without controller to avoid tree crash)"

    page_rows.append([
        pid,
        domain,
        r_const,
        r_path,
        screen_f,
        ctrl_str,
        b_str,
        priority,
        notes
    ])

with open(output_page_inventory, "w", encoding="utf-8", newline="") as f:
    writer = csv.writer(f)
    writer.writerow([
        "id",
        "domain",
        "route_constant",
        "route_path",
        "screen_file",
        "controller_file",
        "binding_file",
        "priority",
        "notes"
    ])
    writer.writerows(page_rows)

print(f"Updated {output_page_inventory} successfully.")
