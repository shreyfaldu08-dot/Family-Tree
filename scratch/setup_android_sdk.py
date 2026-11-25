import os
import sys
import urllib.request
import zipfile
import subprocess
import shutil

SDK_ROOT = r"C:\Users\BAPS\AppData\Local\Android\Sdk"
ZIP_URL = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
ZIP_PATH = r"C:\Users\BAPS\AppData\Local\Android\cmdline-tools.zip"

def main():
    os.makedirs(os.path.dirname(ZIP_PATH), exist_ok=True)
    
    if not os.path.exists(ZIP_PATH):
        print(f"Downloading Android Command Line Tools from {ZIP_URL}...")
        urllib.request.urlretrieve(ZIP_URL, ZIP_PATH)
        print("Download complete. Size:", os.path.getsize(ZIP_PATH))
    else:
        print("ZIP already exists at", ZIP_PATH)

    latest_dir = os.path.join(SDK_ROOT, "cmdline-tools", "latest")
    if not os.path.exists(os.path.join(latest_dir, "bin", "sdkmanager.bat")):
        print(f"Extracting to temporary folder...")
        temp_extract = os.path.join(SDK_ROOT, "temp_extract")
        os.makedirs(temp_extract, exist_ok=True)
        with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(temp_extract)
        
        # The zip typically contains 'cmdline-tools' folder
        extracted_cmdline = os.path.join(temp_extract, "cmdline-tools")
        if not os.path.exists(extracted_cmdline):
            extracted_cmdline = temp_extract

        os.makedirs(os.path.dirname(latest_dir), exist_ok=True)
        if os.path.exists(latest_dir):
            shutil.rmtree(latest_dir)
        shutil.move(extracted_cmdline, latest_dir)
        print("Moved cmdline-tools to", latest_dir)
        shutil.rmtree(temp_extract, ignore_errors=True)

    sdkmanager = os.path.join(latest_dir, "bin", "sdkmanager.bat")
    print("sdkmanager path:", sdkmanager, "exists:", os.path.exists(sdkmanager))

if __name__ == "__main__":
    main()
