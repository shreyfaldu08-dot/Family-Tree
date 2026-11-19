import subprocess
import time
import os

def capture():
    out = r"C:\Users\BAPS\Desktop\application 2\scratch\people_rounded_search_verified.png"
    if os.path.exists(out):
        try:
            os.remove(out)
        except Exception:
            pass

    cmd = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        "--headless=new",
        "--disable-gpu",
        "--virtual-time-budget=6000",
        "--hide-scrollbars",
        f"--screenshot={out}",
        "--window-size=1200,900",
        "http://localhost:8085/#/people"
    ]
    print("Capturing /people screenshot...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("Return code:", res.returncode)
    if os.path.exists(out):
        print("Saved to", out, "Size:", os.path.getsize(out))
    else:
        print("Failed to save screenshot! Stderr:", res.stderr)

if __name__ == "__main__":
    capture()
