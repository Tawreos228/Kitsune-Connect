"""Скачивает ядро sing-box (windows-amd64) в эту папку. Запуск: python core/fetch_core.py"""
import io
import urllib.request
import zipfile
from pathlib import Path

VERSION = "1.13.12"
URL = f"https://github.com/SagerNet/sing-box/releases/download/v{VERSION}/sing-box-{VERSION}-windows-amd64.zip"
DEST = Path(__file__).resolve().parent / "sing-box.exe"


def main() -> None:
    print("Скачиваю sing-box", VERSION, "…")
    data = urllib.request.urlopen(URL).read()
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        name = next(n for n in z.namelist() if n.endswith("sing-box.exe"))
        DEST.write_bytes(z.read(name))
    print("Готово ->", DEST)


if __name__ == "__main__":
    main()
