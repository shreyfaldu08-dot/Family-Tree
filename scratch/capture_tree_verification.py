import subprocess
import time
import sys
import os

def capture():
    output_path = r"C:\Users\BAPS\Desktop\application 2\scratch\tree_no_touching_verified.png"
    if os.path.exists(output_path):
        try:
            os.remove(output_path)
        except Exception:
            pass

    cmd = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        "--headless=new",
        "--disable-gpu",
        "--virtual-time-budget=7000",
        "--hide-scrollbars",
        f"--screenshot={output_path}",
        "--window-size=1600,1000",
        "http://localhost:8085/#/tree"
    ]
    print("Capturing screenshot with Chrome headless...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("Return code:", res.returncode)
    if os.path.exists(output_path):
        print("Screenshot saved to", output_path, "Size:", os.path.getsize(output_path))
    else:
        print("Screenshot not found! Error:", res.stderr)

if __name__ == "__main__":
    capture()
