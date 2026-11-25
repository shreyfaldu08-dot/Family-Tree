import subprocess
import os
import time
import tempfile

def capture_route(route, out_path, window_size="1200,900", delay_ms=8000):
    if os.path.exists(out_path):
        try:
            os.remove(out_path)
        except Exception:
            pass

    temp_dir = tempfile.mkdtemp(prefix="chrome_p1_")
    ts = int(time.time())
    url = f"http://localhost:8085/?v={ts}#{route}"
    cmd = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        "--headless=new",
        "--disable-gpu",
        f"--user-data-dir={temp_dir}",
        f"--virtual-time-budget={delay_ms}",
        "--hide-scrollbars",
        f"--screenshot={out_path}",
        f"--window-size={window_size}",
        url
    ]
    print(f"Capturing {url} at {window_size} -> {os.path.basename(out_path)}...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if os.path.exists(out_path):
        print(f"  OK! Size: {os.path.getsize(out_path)} bytes")
        return True
    else:
        print(f"  FAILED. Stderr: {res.stderr}")
        return False

def main():
    target_dir = r"C:\Users\BAPS\Desktop\application 2\scratch"
    shots = [
        ("/relation", os.path.join(target_dir, "kinship_pathfinder_verified.png"), "1200,950"),
        ("/archive", os.path.join(target_dir, "vault_archive_verified.png"), "1200,950"),
    ]

    for route, path, size in shots:
        capture_route(route, path, size)

if __name__ == "__main__":
    main()
