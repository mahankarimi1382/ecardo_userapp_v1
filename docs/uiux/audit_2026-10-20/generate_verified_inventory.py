import csv
import os
import glob

# 1. Read inventory
inventory_path = 'docs/uiux/PAGE_INVENTORY.csv'
output_path = 'docs/uiux/audit_2026-10-20/ROUTE_INVENTORY_VERIFIED.csv'

inventory = list(csv.DictReader(open(inventory_path, encoding='utf-8')))

# 2. Gather all test files
test_files = glob.glob('test/**/*.dart', recursive=True) + glob.glob('test/*.dart')
test_contents = {}
for tf in test_files:
    try:
        test_contents[tf] = open(tf, encoding='utf-8', errors='ignore').read()
    except Exception:
        pass

# Screenshot / golden test files
golden_test_files = [
    'test/auth_screenshot_test.dart',
    'test/exchange_screenshot_test.dart',
    'test/home_screenshot_test.dart',
    'test/transfer_screenshot_test.dart',
    'test/wallets_screenshot_test.dart',
]
golden_contents = {gf: test_contents.get(gf, '') for gf in golden_test_files}

verified_rows = []

for row in inventory:
    rid = row['id']
    domain = row['domain']
    route_const = row['route_constant']
    route_path = row['route_path']
    screen_files = [s.strip() for s in row['screen_file'].split(';') if s.strip() and s.strip() != 'none']
    controller_files = [c.strip() for c in row['controller_file'].split(';') if c.strip() and c.strip() != 'none']
    priority = row['priority']

    # Check existence
    screens_exist = all(os.path.exists(s) for s in screen_files) if screen_files else True
    controllers_exist = all(os.path.exists(c) for c in controller_files) if controller_files else True

    # Check widget test
    has_widget_test = False
    screen_base_names = [os.path.basename(s).replace('.dart', '') for s in screen_files]
    for s_name in screen_base_names:
        for tf, content in test_contents.items():
            if s_name in content:
                has_widget_test = True
                break
        if has_widget_test:
            break

    # Check golden test
    has_golden = False
    for s_name in screen_base_names:
        for gf, content in golden_contents.items():
            if s_name in content or route_const in content:
                has_golden = True
                break
        if has_golden:
            break

    verified_rows.append({
        'id': rid,
        'route_constant': route_const,
        'route_path': route_path,
        'domain': domain,
        'priority': priority,
        'screen_file': row['screen_file'],
        'controller_file': row['controller_file'],
        'exists_screen': str(screens_exist).upper(),
        'exists_controller': str(controllers_exist).upper(),
        'has_widget_test': str(has_widget_test).upper(),
        'has_golden_test': str(has_golden).upper(),
        'notes': row['notes']
    })

fieldnames = [
    'id', 'route_constant', 'route_path', 'domain', 'priority',
    'screen_file', 'controller_file', 'exists_screen', 'exists_controller',
    'has_widget_test', 'has_golden_test', 'notes'
]

with open(output_path, 'w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(verified_rows)

print(f"Successfully generated {output_path} with {len(verified_rows)} rows!")
print(f"Widget test coverage: {sum(1 for r in verified_rows if r['has_widget_test'] == 'TRUE')}/{len(verified_rows)}")
print(f"Golden test coverage: {sum(1 for r in verified_rows if r['has_golden_test'] == 'TRUE')}/{len(verified_rows)}")
