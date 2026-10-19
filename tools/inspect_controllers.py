import os
import re
from index_classes import class_to_file, controllers, bindings

# Let's inspect where bindings are defined and what controllers they put/lazyPut
for bname, bdata in bindings.items():
    pass

from robust_inspect import parsed_pages

for p in parsed_pages:
    w = p['widget']
    p['widget_file'] = class_to_file.get(w)
    b_list = p['bindings']
    screen_name = p['widget']
    screen_file = p.get('widget_file')
    
    # check controllers registered by bindings
    b_files = []
    ctrl_names = []
    ctrl_files = []
    
    for b in b_list:
        b_info = bindings.get(b)
        if b_info:
            b_files.append(b_info['file'])
            for c in b_info['registered']:
                ctrl_names.append(c)
                c_file = class_to_file.get(c)
                if c_file:
                    ctrl_files.append(c_file)
                else:
                    ctrl_files.append(f"NOT_FOUND:{c}")
        else:
            b_files.append(f"NOT_FOUND:{b}")
            
    # If no bindings, check if screen widget has Get.put or Get.lazyPut or Get.find
    if not b_list and screen_file and os.path.exists(screen_file):
        with open(screen_file, "r", encoding="utf-8") as sf:
            s_text = sf.read()
        inline_ctrls = re.findall(r'Get\.(?:lazyPut|put|find)<([A-Za-z0-9_]+Controller)>', s_text)
        if inline_ctrls:
            for ic in inline_ctrls:
                ctrl_names.append(ic)
                c_file = class_to_file.get(ic)
                if c_file:
                    ctrl_files.append(c_file)
                else:
                    ctrl_files.append(f"NOT_FOUND:{ic}")

    p['binding_classes'] = b_list
    p['binding_files'] = list(dict.fromkeys(b_files))
    p['controller_classes'] = list(dict.fromkeys(ctrl_names))
    p['controller_files'] = list(dict.fromkeys(ctrl_files))

print("Binding & Controller analysis sample:")
for p in parsed_pages[:10]:
    print(f"Route: BaseRoute.{p['name']}")
    print(f"  Screen: {p['widget']} -> {p['widget_file']}")
    print(f"  Bindings: {p['binding_classes']} -> {p['binding_files']}")
    print(f"  Controllers: {p['controller_classes']} -> {p['controller_files']}")
    print()
