import os
import subprocess
import sys

SDK_ROOT = r"C:\Users\BAPS\AppData\Local\Android\Sdk"
SDKMANAGER = os.path.join(SDK_ROOT, "cmdline-tools", "latest", "bin", "sdkmanager.bat")
JAVA_HOME = r"C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"

env = os.environ.copy()
env["JAVA_HOME"] = JAVA_HOME
env["ANDROID_HOME"] = SDK_ROOT
env["PATH"] = os.path.join(JAVA_HOME, "bin") + ";" + env["PATH"]

def install():
    packages = ["platform-tools", "platforms;android-34", "build-tools;34.0.0"]
    cmd = [SDKMANAGER, f"--sdk_root={SDK_ROOT}"] + packages
    print("Running sdkmanager to install:", packages)
    
    # We pipe 'y\n' * 50 to accept licenses
    p = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=env,
        text=True
    )
    
    stdout, _ = p.communicate(input="y\n" * 50)
    print("Return code:", p.returncode)
    # Print last 30 lines of output
    lines = stdout.splitlines()
    for l in lines[-30:]:
        print(l)

    # Accept all licenses
    print("\nAccepting all licenses...")
    lic_cmd = [SDKMANAGER, f"--sdk_root={SDK_ROOT}", "--licenses"]
    p2 = subprocess.Popen(
        lic_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        env=env,
        text=True
    )
    stdout2, _ = p2.communicate(input="y\n" * 100)
    print("Licenses return code:", p2.returncode)
    for l in stdout2.splitlines()[-20:]:
        print(l)

if __name__ == "__main__":
    install()
