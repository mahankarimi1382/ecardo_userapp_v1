with open('lib/src/app/routes/routes_config.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'static' in line:
        print(f"{i+1}: {line.strip()}")
