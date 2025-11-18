#!/usr/bin/env python3
import re
from pathlib import Path
import sys

if len(sys.argv) != 2:
    print("Usage: python sync_version.py <path to LibVersion.h>")
    sys.exit(1)

header_file = Path(sys.argv[1])
if not header_file.exists():
    print(f"ERROR: Header file not found: {header_file}")
    sys.exit(1)

# Python files to update
PYTHON_FILES = [
    "conanfile.py",
    "ims-lib/conanfile.py",
    "pyproject.toml",
]

# Read header and extract version
text = header_file.read_text()
major = re.search(r"#define\s+IMS_API_MAJOR\s+(\d+)", text)
minor = re.search(r"#define\s+IMS_API_MINOR\s+(\d+)", text)
patch = re.search(r"#define\s+IMS_API_PATCH\s+(\d+)", text)

if not (major and minor and patch):
    print("ERROR: Could not find IMS_API_MAJOR/MINOR/PATCH in header")
    sys.exit(1)

version_str = f"{major.group(1)}.{minor.group(1)}.{patch.group(1)}"
print(f"Syncing Python version to C++ version: {version_str}")

# Update files
for pyfile in PYTHON_FILES:
    path = Path(pyfile)
    if not path.exists():
        print(f"WARNING: {path} not found, skipping")
        continue

    content = path.read_text()
    content_new = re.sub(
        r'(version\s*=\s*")[0-9]+\.[0-9]+\.[0-9]+(")',
        lambda m: f'{m.group(1)}{version_str}{m.group(2)}',
        content
    )
    content_new = re.sub(
        r'(version\s*:\s*")[0-9]+\.[0-9]+\.[0-9]+(")',
        lambda m: f'{m.group(1)}{version_str}{m.group(2)}',
        content_new
    )
    path.write_text(content_new)
    print(f"Updated {path}")
