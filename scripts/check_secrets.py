"""Check every Git-tracked working-tree file without printing secret values."""

from pathlib import Path
import re
import subprocess
import sys


PATTERNS = {
    "Google API key": rb"AIza[0-9A-Za-z_-]{35}",
    "GitHub token": rb"(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})",
    "AWS access key": rb"(?:AKIA|ASIA)[0-9A-Z]{16}",
    "Private key": rb"-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----",
    "OpenAI-style key": rb"sk-[A-Za-z0-9_-]{32,}",
}


def scan(data):
    for kind, pattern in PATTERNS.items():
        for match in re.finditer(pattern, data):
            yield kind, data.count(b"\n", 0, match.start()) + 1


def main():
    root = Path(__file__).resolve().parents[1]
    paths = subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=root
    ).decode("utf-8").split("\0")
    findings = 0
    checked = 0
    for name in filter(None, paths):
        path = root / name
        if not path.is_file():
            continue
        checked += 1
        for kind, line in scan(path.read_bytes()):
            print(f"{name}:{line}: {kind}")
            findings += 1
    print(f"Checked {checked} tracked files; {findings} potential secrets.")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
