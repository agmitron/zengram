#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def touch_dependency_files(search_root: Path) -> int:
    touched = 0
    for output_map in search_root.rglob("*-OutputFileMap.json"):
        try:
            data = json.loads(output_map.read_text())
        except Exception:
            continue
        primary = data.get("") or {}
        dep_path = primary.get("dependencies")
        if not dep_path:
            continue
        dep_file = Path(dep_path)
        try:
            dep_file.parent.mkdir(parents=True, exist_ok=True)
            dep_file.touch(exist_ok=True)
            touched += 1
        except Exception:
            continue
    return touched


def main() -> int:
    if len(sys.argv) > 1:
        root = Path(sys.argv[1]).expanduser()
    else:
        root = Path.home() / "Library/Developer/Xcode/DerivedData"

    if not root.exists():
        return 0

    touched = touch_dependency_files(root)
    if "--verbose" in sys.argv and touched:
        print(f"touched {touched} dependency files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
