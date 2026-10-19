import os
import re

from robust_inspect import base_routes, parsed_pages, rc_props
from index_classes import class_to_file, controllers, bindings, screens

# Let's verify mapping for every parsed page
unmapped_widgets = []
for p in parsed_pages:
    w = p['widget']
    if not w:
        unmapped_widgets.append(p)
    else:
        # Check if screen exists in screens or class_to_file
        file_loc = class_to_file.get(w)
        p['widget_file'] = file_loc

print(f"Total unmapped widgets: {len(unmapped_widgets)}")
if unmapped_widgets:
    for u in unmapped_widgets:
        print("  Unmapped:", u['name'], u['body'][:100])

missing_screen_files = [p for p in parsed_pages if not p.get('widget_file')]
print(f"Widgets with missing file location: {len(missing_screen_files)}")
for m in missing_screen_files:
    print("  Missing file for widget:", m['name'], m['widget'])
