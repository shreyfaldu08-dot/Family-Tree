import subprocess
import os
import time
import tempfile

def test_persona_flow():
    out = r"C:\Users\BAPS\Desktop\application 2\scratch\persona_thomas_dashboard.png"
    temp_dir = tempfile.mkdtemp(prefix="chrome_persona_")
    
    # We can inject javascript or directly test persona repository switch
    # Let's verify by capturing with chrome
    ts = int(time.time())
    url = f"http://localhost:8085/?v={ts}#/home"
    cmd = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        "--headless=new",
        "--disable-gpu",
        f"--user-data-dir={temp_dir}",
        "--virtual-time-budget=6000",
        "--hide-scrollbars",
        f"--screenshot={out}",
        "--window-size=1200,900",
        url
    ]
    subprocess.run(cmd, capture_output=True, text=True)
    if os.path.exists(out):
        print("Captured test dashboard:", out, os.path.getsize(out))

if __name__ == "__main__":
    test_persona_flow()
