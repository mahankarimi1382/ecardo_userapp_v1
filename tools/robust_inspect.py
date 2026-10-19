import os
import re

base_dir = os.path.abspath(".")
routes_file = os.path.join(base_dir, "lib", "src", "app", "routes", "routes.dart")
routes_config_file = os.path.join(base_dir, "lib", "src", "app", "routes", "routes_config.dart")
routes_handler_file = os.path.join(base_dir, "lib", "src", "app", "routes", "routes_handler.dart")

with open(routes_file, "r", encoding="utf-8") as f:
    routes_dart = f.read()

with open(routes_config_file, "r", encoding="utf-8") as f:
    routes_config_dart = f.read()

with open(routes_handler_file, "r", encoding="utf-8") as f:
    routes_handler_dart = f.read()

# 1. Parse BaseRoute constants properly across multiple lines
# Regex: static\s+(?:const\s+)?(?:String\s+)?(\w+)\s*=\s*["']([^"']+)["']
base_routes = {}
for m in re.finditer(r'static\s+(?:const\s+)?(?:String\s+)?(\w+)\s*=\s*["\']([^"\']+)["\'];', routes_dart, re.DOTALL):
    base_routes[m.group(1)] = m.group(2)

print(f"Total BaseRoute constants found: {len(base_routes)}")

# 2. Parse RoutesConfig properties across multiple lines
rc_props = {}
for m in re.finditer(r'static\s+(?:const|final)\s+(?:[A-Za-z0-9_<>]+\s+)?(\w+)\s*=\s*(?:const\s+)?([A-Za-z0-9_]+)\(', routes_config_dart):
    rc_props[m.group(1)] = m.group(2)

print(f"Total RoutesConfig props found: {len(rc_props)}")

# 3. Parse GetPage calls by matching balanced parentheses
def extract_get_pages(text):
    pages = []
    idx = 0
    while True:
        pos = text.find('GetPage(', idx)
        if pos == -1:
            break
        # find matching closing parenthesis
        depth = 0
        start = pos + len('GetPage(')
        in_string = False
        str_char = ''
        end = start
        for i in range(start - 1, len(text)):
            c = text[i]
            if in_string:
                if c == str_char and text[i-1] != '\\':
                    in_string = False
            else:
                if c in ('"', "'"):
                    in_string = True
                    str_char = c
                elif c == '(':
                    depth += 1
                elif c == ')':
                    depth -= 1
                    if depth == 0:
                        end = i
                        break
        body = text[start:end]
        pages.append(body)
        idx = end + 1
    return pages

get_page_bodies = extract_get_pages(routes_handler_dart)
print(f"Total GetPage calls extracted: {len(get_page_bodies)}")

parsed_pages = []
for body in get_page_bodies:
    name_m = re.search(r'name\s*:\s*BaseRoute\.(\w+)', body)
    name = name_m.group(1) if name_m else None
    
    rc_m = re.search(r'RoutesConfig\.(\w+)', body)
    # direct constructor: page: () => const CommercialProjectsScreen(), or page: () => ReplayTicket(...)
    direct_m = re.search(r'page\s*:\s*\(\)\s*=>\s*(?:const\s+)?([A-Za-z0-9_]+)\(', body)
    return_m = re.search(r'return\s+([A-Za-z0-9_]+)\s*\(', body)
    
    widget = None
    if rc_m:
        widget = rc_props.get(rc_m.group(1), f"RC_{rc_m.group(1)}")
    elif direct_m:
        widget = direct_m.group(1)
    elif return_m:
        widget = return_m.group(1)
        
    bindings = re.findall(r'([A-Za-z0-9_]+Binding)\s*\(', body)
    
    parsed_pages.append({
        'name': name,
        'widget': widget,
        'bindings': bindings,
        'body': body
    })

print("\n--- Summary of Routes in routesHandler ---")
registered_names = set(p['name'] for p in parsed_pages if p['name'])
declared_names = set(base_routes.keys())

print(f"Declared: {len(declared_names)}")
print(f"Registered: {len(registered_names)}")
print(f"Total GetPage calls: {len(parsed_pages)}")

orphans_declared = declared_names - registered_names
orphans_registered = registered_names - declared_names

print(f"Declared but not registered: {orphans_declared}")
print(f"Registered but not declared: {orphans_registered}")

# Check duplicates in registered GetPages
from collections import Counter
counts = Counter(p['name'] for p in parsed_pages)
for name, cnt in counts.items():
    if cnt > 1:
        print(f"Duplicate registration: BaseRoute.{name} registered {cnt} times")

