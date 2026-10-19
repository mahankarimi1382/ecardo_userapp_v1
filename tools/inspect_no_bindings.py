import json

with open('tools/routes_summary.json', 'r', encoding='utf-8') as f:
    routes = json.load(f)

no_b = [r for r in routes if not r['bindings']]
print(f"Routes with no binding: {len(no_b)}")
for r in no_b:
    print(f"{r['route_constant']} | {r['screen_widget']} | {r['screen_file']}")
