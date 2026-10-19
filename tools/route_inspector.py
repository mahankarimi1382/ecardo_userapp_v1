import os
import re
import csv
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

# 1. Parse BaseRoute constants
# e.g.: static const String root = "/"; or static const noInternetConnection = '/no_internet_connection';
base_route_constants = {}
for line in routes_dart.splitlines():
    line = line.strip()
    m = re.match(r'static\s+(?:const\s+)?(?:String\s+)?(\w+)\s*=\s*["\']([^"\']+)["\'];?', line)
    if m:
        name = m.group(1)
        val = m.group(2)
        base_route_constants[name] = val

print(f"Found {len(base_route_constants)} constants in BaseRoute.")

# 2. Parse RoutesConfig mappings and imports
# First, imports in routes_config.dart
rc_imports = []
for line in routes_config_dart.splitlines():
    m = re.match(r'import\s+["\']([^"\']+)["\'];', line.strip())
    if m:
        rc_imports.append(m.group(1))

# RoutesConfig properties: e.g. static const splash = SplashScreen();
rc_props = {}
for line in routes_config_dart.splitlines():
    m = re.match(r'static\s+(?:const|final)\s+(?:[A-Za-z0-9_<>]+)?\s*(\w+)\s*=\s*(?:const\s+)?([A-Za-z0-9_]+)\(', line.strip())
    if m:
        prop = m.group(1)
        widget = m.group(2)
        rc_props[prop] = widget

print(f"Found {len(rc_props)} properties in RoutesConfig.")

# 3. Parse routesHandler GetPage definitions
# GetPage(
#   name: BaseRoute.root,
#   page: () => RoutesConfig.splash,
#   binding: SplashBinding(),
# )
# Or bindings: [...]
# Or page: () => const EscrowCreateScreen()
# Or page: () { ... return TourDetailScreen(...) ... }

# Let's write a regex/parser to extract each GetPage block
get_page_blocks = re.findall(r'GetPage\s*\((.*?)\)(?=\s*(?:,\s*GetPage|,\s*\]|\]))', routes_handler_dart, re.DOTALL)
print(f"Found {len(get_page_blocks)} GetPage entries in routesHandler.")

pages_info = []
for block in get_page_blocks:
    name_m = re.search(r'name\s*:\s*BaseRoute\.(\w+)', block)
    name = name_m.group(1) if name_m else None
    
    # check page
    page_rc_m = re.search(r'RoutesConfig\.(\w+)', block)
    page_widget_m = re.search(r'return\s+([A-Za-z0-9_]+)\s*\(', block)
    if not page_widget_m:
        page_widget_m = re.search(r'page\s*:\s*\(\)\s*=>\s*(?:const\s+)?([A-Za-z0-9_]+)\s*\(', block)
    
    binding_m = re.search(r'binding\s*:\s*([A-Za-z0-9_]+)\s*\(', block)
    bindings_m = re.findall(r'([A-Za-z0-9_]+Binding)\s*\(', block)
    
    pages_info.append({
        'block': block,
        'route_name': name,
        'rc_prop': page_rc_m.group(1) if page_rc_m else None,
        'widget_direct': page_widget_m.group(1) if page_widget_m else None,
        'single_binding': binding_m.group(1) if binding_m else None,
        'all_bindings': bindings_m
    })

print(f"Parsed {len(pages_info)} pages info.")
