import os
import subprocess

SDK_ROOT = r"C:\Users\BAPS\AppData\Local\Android\Sdk"
SDKMANAGER = os.path.join(SDK_ROOT, "cmdline-tools", "latest", "bin", "sdkmanager.bat")
JAVA_HOME = r"C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"

env = os.environ.copy()
env["JAVA_HOME"] = JAVA_HOME
env["ANDROID_HOME"] = SDK_ROOT
env["PATH"] = os.path.join(JAVA_HOME, "bin") + ";" + env["PATH"]

def run():
    # Install android-36 or android-35
    cmd = [SDKMANAGER, f"--sdk_root={SDK_ROOT}", "platforms;android-36", "platforms;android-35", "build-tools;35.0.0", "build-tools;34.0.0"]
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env)
    stdout, _ = p.communicate(input=b"y\n" * 50)
    print("Code:", p.returncode)
    try:
        text = stdout.decode('utf-8', errors='replace')
        lines = text.splitlines()
        for l in lines[-25:]:
            print(l)
    except Exception as e:
        print("Error decoding:", e)

if __name__ == "__main__":
    run()
