import subprocess
import os
import time
import tempfile

def capture():
    out = r"C:\Users\BAPS\Desktop\application 2\scratch\profile_screen_verified.png"
    if os.path.exists(out):
        try:
            os.remove(out)
        except Exception:
            pass

    temp_dir = tempfile.mkdtemp(prefix="chrome_profile_")
    ts = int(time.time())
    cmd = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        "--headless=new",
        "--disable-gpu",
        f"--user-data-dir={temp_dir}",
        "--virtual-time-budget=8000",
        "--hide-scrollbars",
        f"--screenshot={out}",
        "--window-size=1200,900",
        f"http://localhost:8085/?v={ts}#/profile"
    ]
    print(f"Capturing /profile screenshot with cache buster v={ts}...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    print("Return code:", res.returncode)
    if os.path.exists(out):
        print("Saved to", out, "Size:", os.path.getsize(out))
    else:
        print("Failed to save screenshot! Stderr:", res.stderr)

if __name__ == "__main__":
    capture()
