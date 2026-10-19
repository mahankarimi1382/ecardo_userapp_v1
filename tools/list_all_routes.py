import os
import re
import json

from parse_precise_classes import class_to_file, controllers, bindings, screens
from robust_inspect import base_routes, parsed_pages, rc_props

routes_summary = []

for i, p in enumerate(parsed_pages, 1):
    name = p['name']
    path = base_routes.get(name, '')
    widget = p['widget']
    widget_file = class_to_file.get(widget, 'NOT_FOUND')
    
    # bindings
    b_list = p['bindings']
    b_files = []
    ctrl_list = []
    ctrl_files = []
    
    for b in b_list:
        b_data = bindings.get(b)
        if b_data:
            b_files.append(b_data['file'])
            for c in b_data['registered']:
                ctrl_list.append(c)
                cf = controllers.get(c, class_to_file.get(c))
                if cf:
                    ctrl_files.append(cf)
                else:
                    ctrl_files.append(f"UNKNOWN_CTRL_FILE:{c}")
        else:
            b_files.append(f"UNKNOWN_BINDING:{b}")
            
    # inline controller check if no binding
    if not b_list and widget_file != 'NOT_FOUND' and os.path.exists(widget_file):
        with open(widget_file, 'r', encoding='utf-8') as wf:
            wtext = wf.read()
        inline = re.findall(r'Get\.(?:put|lazyPut|find)<([A-Za-z0-9_]+Controller)>', wtext)
        for ic in inline:
            ctrl_list.append(ic)
            cf = controllers.get(ic, class_to_file.get(ic))
            if cf:
                ctrl_files.append(cf)
            else:
                ctrl_files.append(f"UNKNOWN_CTRL_FILE:{ic}")

    b_files_clean = list(dict.fromkeys(b_files))
    ctrl_files_clean = list(dict.fromkeys(ctrl_files))
    ctrl_names_clean = list(dict.fromkeys(ctrl_list))
    b_names_clean = list(dict.fromkeys(b_list))
    
    routes_summary.append({
        'id': f"ROUTE-{i:03d}",
        'route_constant': f"BaseRoute.{name}",
        'route_path': path,
        'screen_widget': widget,
        'screen_file': widget_file,
        'bindings': b_names_clean,
        'binding_files': b_files_clean,
        'controllers': ctrl_names_clean,
        'controller_files': ctrl_files_clean
    })

with open("tools/routes_summary.json", "w", encoding="utf-8") as f:
    json.dump(routes_summary, f, indent=2, ensure_ascii=False)

print(f"Exported {len(routes_summary)} routes to tools/routes_summary.json")
