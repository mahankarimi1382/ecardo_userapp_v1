import os
import re

lib_src = os.path.abspath("lib/src")

class_to_file = {}
controllers = {}
bindings = {}
screens = {}

# We will parse files, extract each class definition and its body
def parse_classes_in_file(file_path, rel_path, content):
    # Regex to find class declarations and their start
    # class Foo extends Bar implements Baz {
    class_pattern = re.compile(r'class\s+([A-Za-z0-9_]+)(?:\s+extends\s+([A-Za-z0-9_<>]+))?(?:\s+with\s+([A-Za-z0-9_,\s<>]+))?(?:\s+implements\s+([A-Za-z0-9_,\s<>]+))?\s*\{')
    
    matches = list(class_pattern.finditer(content))
    for i, m in enumerate(matches):
        cname = m.group(1)
        extends = m.group(2) or ""
        with_ = m.group(3) or ""
        impl = m.group(4) or ""
        
        start_idx = m.end() - 1 # at '{'
        # find matching '}'
        depth = 0
        in_string = False
        str_char = ''
        end_idx = len(content)
        for j in range(start_idx, len(content)):
            c = content[j]
            if in_string:
                if c == str_char and content[j-1] != '\\':
                    in_string = False
            else:
                if c in ('"', "'"):
                    in_string = True
                    str_char = c
                elif c == '{':
                    depth += 1
                elif c == '}':
                    depth -= 1
                    if depth == 0:
                        end_idx = j + 1
                        break
        body = content[start_idx:end_idx]
        
        class_to_file[cname] = rel_path
        if "Controller" in extends or "GetxController" in extends or cname.endswith("Controller"):
            controllers[cname] = rel_path
        if "Binding" in impl or "Bindings" in impl or cname.endswith("Binding"):
            registered = re.findall(r'Get\.(?:lazyPut|put)<([A-Za-z0-9_]+)>', body)
            # also handle Get.put(FooController()) without type param
            for put_match in re.finditer(r'Get\.(?:lazyPut|put)\s*(?:<([A-Za-z0-9_]+)>)?\s*\(\s*(?:\(\)\s*=>\s*)?(?:const\s+)?([A-Za-z0-9_]+Controller)\(', body):
                ctrl = put_match.group(1) or put_match.group(2)
                if ctrl and ctrl not in registered:
                    registered.append(ctrl)
            bindings[cname] = {
                "file": rel_path,
                "registered": registered
            }
        if "Screen" in cname or "View" in cname or "Widget" in extends or "StatelessWidget" in extends or "StatefulWidget" in extends:
            screens[cname] = rel_path

for root, dirs, files in os.walk(lib_src):
    for f in files:
        if f.endswith(".dart"):
            file_path = os.path.join(root, f)
            rel_path = os.path.relpath(file_path, start=os.path.abspath(".")).replace("\\", "/")
            try:
                with open(file_path, "r", encoding="utf-8") as dart_f:
                    content = dart_f.read()
                parse_classes_in_file(file_path, rel_path, content)
            except Exception as e:
                pass

print(f"Indexed {len(class_to_file)} classes.")
print(f"Controllers: {len(controllers)}")
print(f"Bindings: {len(bindings)}")

# Test a few bindings
for b in ['SplashBinding', 'SignInBinding', 'TransferBinding', 'WalletsBinding', 'TourBinding']:
    print(f"{b}: file={bindings.get(b, {}).get('file')}, registered={bindings.get(b, {}).get('registered')}")
