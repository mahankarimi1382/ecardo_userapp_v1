import os
import re

lib_src = os.path.abspath("lib/src")

class_to_file = {}
controllers = {}
bindings = {}
screens = {}

for root, dirs, files in os.walk(lib_src):
    for f in files:
        if f.endswith(".dart"):
            file_path = os.path.join(root, f)
            rel_path = os.path.relpath(file_path, start=os.path.abspath(".")).replace("\\", "/")
            try:
                with open(file_path, "r", encoding="utf-8") as dart_f:
                    content = dart_f.read()
            except Exception as e:
                continue
            
            # Find class definitions
            # class Foo extends ...
            for m in re.finditer(r'class\s+([A-Za-z0-9_]+)(?:\s+extends\s+([A-Za-z0-9_]+))?(?:\s+with\s+([A-Za-z0-9_,\s]+))?(?:\s+implements\s+([A-Za-z0-9_,\s]+))?', content):
                cname = m.group(1)
                extends = m.group(2) or ""
                with_ = m.group(3) or ""
                impl = m.group(4) or ""
                class_to_file[cname] = rel_path
                
                if "Controller" in extends or "GetxController" in extends or cname.endswith("Controller"):
                    controllers[cname] = rel_path
                if "Binding" in impl or "Bindings" in impl or cname.endswith("Binding"):
                    # Find what controllers this binding registers
                    registered = re.findall(r'Get\.(?:lazyPut|put)<([A-Za-z0-9_]+)>', content)
                    bindings[cname] = {
                        "file": rel_path,
                        "registered": registered
                    }
                if "Screen" in cname or "View" in cname or "Widget" in extends or "StatelessWidget" in extends or "StatefulWidget" in extends:
                    screens[cname] = rel_path

print(f"Indexed {len(class_to_file)} classes.")
print(f"Controllers: {len(controllers)}")
print(f"Bindings: {len(bindings)}")
print(f"Screens/Widgets: {len(screens)}")
