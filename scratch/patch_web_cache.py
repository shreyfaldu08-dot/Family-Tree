import time
import re

def patch():
    path = r"build\web\flutter_bootstrap.js"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    ts = str(int(time.time()))
    # Replace "mainJsPath":"main.dart.js" with "mainJsPath":"main.dart.js?v=" + ts
    content = content.replace('"mainJsPath":"main.dart.js"', f'"mainJsPath":"main.dart.js?v={ts}"')
    
    # Remove serviceWorkerSettings
    content = re.sub(r'serviceWorkerSettings:\s*\{[^}]*\}', '', content)

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Patched {path} with cache buster v={ts}")

if __name__ == "__main__":
    patch()
