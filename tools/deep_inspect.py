import os
import re
import json

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

# BaseRoute constants
base_routes = {}
for line in routes_dart.splitlines():
    line = line.strip()
    m = re.match(r'static\s+(?:const\s+)?(?:String\s+)?(\w+)\s*=\s*["\']([^"\']+)["\'];?', line)
    if m:
        base_routes[m.group(1)] = m.group(2)

print(f"Total BaseRoute constants: {len(base_routes)}")

# RoutesConfig properties
# static const splash = SplashScreen();
# static final dynamicPassword = const DynamicPasswordScreen();
rc_props = {}
for line in routes_config_dart.splitlines():
    line = line.strip()
    m = re.match(r'static\s+(?:const|final)\s+(?:[A-Za-z0-9_<>]+\s+)?(\w+)\s*=\s*(?:const\s+)?([A-Za-z0-9_]+)\(', line)
    if m:
        rc_props[m.group(1)] = m.group(2)

print(f"Total RoutesConfig props: {len(rc_props)}")

# Parse GetPages in routes_handler.dart
# We can find all GetPage(...)
# Because GetPage can span multiple lines, let's split or match carefully
# Let's find each GetPage block
raw_pages = re.findall(r'GetPage\s*\((.*?)\n\s*\),?', routes_handler_dart, re.DOTALL)
print(f"Total GetPages matched: {len(raw_pages)}")

parsed_getpages = []
for p in raw_pages:
    name_m = re.search(r'name\s*:\s*BaseRoute\.(\w+)', p)
    name = name_m.group(1) if name_m else None
    
    # Page widget
    # Could be RoutesConfig.<prop>
    rc_m = re.search(r'RoutesConfig\.(\w+)', p)
    # Could be direct constructor: page: () => const CommercialProjectsScreen(),
    direct_m = re.search(r'page\s*:\s*\(\)\s*=>\s*(?:const\s+)?([A-Za-z0-9_]+)\(', p)
    # Could be multi-line block with return: return EscrowDetailScreen(...);
    return_m = re.search(r'return\s+([A-Za-z0-9_]+)\s*\(', p)
    
    widget_class = None
    if rc_m:
        widget_class = rc_props.get(rc_m.group(1), f"RC_UNKNOWN_{rc_m.group(1)}")
    elif direct_m:
        widget_class = direct_m.group(1)
    elif return_m:
        widget_class = return_m.group(1)
        
    # Bindings
    # single binding: binding: SplashBinding(),
    single_b = re.search(r'binding\s*:\s*([A-Za-z0-9_]+Binding)\s*\(', p)
    # multiple bindings: bindings: [ ... ]
    all_b = re.findall(r'([A-Za-z0-9_]+Binding)\s*\(', p)
    
    parsed_getpages.append({
        'route_const_name': name,
        'widget_class': widget_class,
        'bindings': all_b,
        'raw': p.strip()
    })

registered_const_names = set(p['route_const_name'] for p in parsed_getpages if p['route_const_name'])
declared_const_names = set(base_routes.keys())

orphan_declared = declared_const_names - registered_const_names
orphan_registered = registered_const_names - declared_const_names

print("\n--- Route Analysis ---")
print(f"Declared in BaseRoute: {len(declared_const_names)}")
print(f"Registered in routesHandler: {len(registered_const_names)} (total GetPage blocks: {len(parsed_getpages)})")
print(f"Declared but NOT registered in routesHandler (orphan declared): {orphan_declared}")
print(f"Registered but NOT declared in BaseRoute: {orphan_registered}")

# Check any GetPage without route_const_name
unmatched_getpages = [p for p in parsed_getpages if not p['route_const_name']]
print(f"GetPages without BaseRoute name: {len(unmatched_getpages)}")

