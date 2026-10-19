import json

with open("tools/routes_summary.json", "r", encoding="utf-8") as f:
    routes = json.load(f)

not_found_screens = [r for r in routes if r['screen_file'] == 'NOT_FOUND']
unknown_bindings = [r for r in routes if any('UNKNOWN' in b for b in r['binding_files'])]
unknown_ctrls = [r for r in routes if any('UNKNOWN' in c for c in r['controller_files'])]

print(f"Not found screens: {len(not_found_screens)}")
print(f"Unknown bindings: {len(unknown_bindings)}")
if unknown_bindings:
    for u in unknown_bindings:
        print(f"  {u['route_constant']}: {u['binding_files']}")

print(f"Unknown controllers: {len(unknown_ctrls)}")
if unknown_ctrls:
    for u in unknown_ctrls:
        print(f"  {u['route_constant']}: {u['controller_files']}")
