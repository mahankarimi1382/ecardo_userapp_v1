import json
import os

with open("tools/routes_classified.json", "r", encoding="utf-8") as f:
    routes = json.load(f)

for r in routes:
    valid_ctrl_files = []
    for cf in r['controller_files']:
        if cf.startswith("UNKNOWN"):
            continue
        if os.path.exists(cf):
            valid_ctrl_files.append(cf)
        else:
            print(f"Warning: controller file does not exist: {cf}")
    r['clean_controller_files'] = list(dict.fromkeys(valid_ctrl_files))
    
    valid_b_files = []
    for bf in r['binding_files']:
        if bf.startswith("UNKNOWN"):
            continue
        if os.path.exists(bf):
            valid_b_files.append(bf)
        else:
            print(f"Warning: binding file does not exist: {bf}")
    r['clean_binding_files'] = list(dict.fromkeys(valid_b_files))

print("Sanitization check complete.")

# Let's inspect routes that have clean_controller_files empty to see if they have inline controllers
empty_ctrls = [r for r in routes if not r['clean_controller_files']]
print(f"Routes with no controller: {len(empty_ctrls)}")
for ec in empty_ctrls:
    print(f"  {ec['route_constant']}: {ec['screen_widget']} ({ec['screen_file']})")
