import shutil
import os

src = r"build\app\outputs\flutter-apk\app-release.apk"
dests = [
    r"c:\Users\BAPS\Desktop\application 2\family_legacy_release.apk",
    r"c:\Users\BAPS\Desktop\application 2\build\web\family_legacy_release.apk",
    r"C:\Users\BAPS\Desktop\family_legacy_release.apk",
    r"C:\Users\BAPS\.gemini\antigravity\brain\0f85ee77-9b07-4def-8188-f53272f7ca46\family_legacy_release.apk"
]

print("Source size:", os.path.getsize(src), "bytes")
for d in dests:
    os.makedirs(os.path.dirname(d), exist_ok=True)
    shutil.copy2(src, d)
    print(f"Copied to: {d} ({os.path.getsize(d):,} bytes)")
