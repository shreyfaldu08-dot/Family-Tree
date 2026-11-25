import os
import urllib.request
import sys

target_dir = r"C:\Users\BAPS\.gradle\wrapper\dists\gradle-9.3.1-all\9ot9r568e8zfvvd4mn8rbu1j0"
part_file = os.path.join(target_dir, "gradle-9.3.1-all.zip.part")
zip_file = os.path.join(target_dir, "gradle-9.3.1-all.zip")
url = "https://services.gradle.org/distributions/gradle-9.3.1-all.zip"

def download():
    if os.path.exists(part_file):
        try:
            os.remove(part_file)
        except Exception:
            pass

    print(f"Downloading {url} to {zip_file}...")
    def reporthook(count, block_size, total_size):
        percent = int(count * block_size * 100 / total_size)
        if count % 200 == 0:
            sys.stdout.write(f"\rProgress: {percent}% ({count * block_size // (1024*1024)}MB / {total_size // (1024*1024)}MB)")
            sys.stdout.flush()

    urllib.request.urlretrieve(url, zip_file, reporthook=reporthook)
    print("\nDownload complete! File size:", os.path.getsize(zip_file))

if __name__ == "__main__":
    download()
