#!/bin/bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/../.." && pwd)"

derived_data_root="${DERIVED_DATA_DIR:-$HOME/Library/Developer/Xcode/DerivedData}"
if [[ ! -d "$derived_data_root" ]]; then
  echo "DerivedData not found at $derived_data_root" >&2
  exit 1
fi

latest_derived_data="$derived_data_root"
latest_derived_data="$(python3 - "$derived_data_root" <<'PY'
from pathlib import Path
import sys

if len(sys.argv) < 2:
    sys.exit(0)

root = Path(sys.argv[1])
paths = [p for p in root.iterdir() if p.is_dir() and p.name.startswith("Telegram-")]
if not paths:
    sys.exit(0)
latest = max(paths, key=lambda p: p.stat().st_mtime)
print(latest)
PY
)"

if [[ -z "$latest_derived_data" ]]; then
  latest_derived_data="$derived_data_root"
fi

config_build_dir="${CONFIGURATION_BUILD_DIR:-$latest_derived_data/Build/Products/Debug-iphonesimulator/xcodebuild}"

python3 "$project_root/build-system/scripts/touch-swift-deps.py" "$latest_derived_data"

if [[ -n "${DEVELOPER_DIR:-}" && -x "$DEVELOPER_DIR/usr/bin/xcodebuild" ]]; then
  :
elif [[ -x "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

if [[ -z "${DEVELOPER_DIR:-}" || ! -x "$DEVELOPER_DIR/usr/bin/xcodebuild" ]]; then
  echo "xcodebuild not found in DEVELOPER_DIR" >&2
  exit 1
fi
export TOOLCHAINS="${TOOLCHAINS:-com.apple.dt.toolchain.XcodeDefault}"

scheme="${SCHEME:-Telegram}"
configuration="${CONFIGURATION:-Debug}"
destination="${DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro}"

"$DEVELOPER_DIR/usr/bin/xcodebuild" \
  -project "$project_root/Telegram/Telegram.xcodeproj" \
  -scheme "$scheme" \
  -configuration "$configuration" \
  -destination "$destination" \
  build \
  CONFIGURATION_BUILD_DIR="$config_build_dir"
