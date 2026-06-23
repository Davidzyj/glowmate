#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/build/DerivedData-screenshots"
LOG_DIR="$ROOT_DIR/build/logs"
OUT_DIR="$ROOT_DIR/screenshots/iphone-6.5/en"
PROJECT="$ROOT_DIR/GlowMate.xcodeproj"
SCHEME="GlowMate"
BUNDLE_ID="com.zhouyajie.glowmate"
DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro Max}"
OS_VERSION="${OS_VERSION:-26.2}"

mkdir -p "$LOG_DIR" "$OUT_DIR"

echo "Building $SCHEME for screenshots..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME,OS=$OS_VERSION" \
  -derivedDataPath "$DERIVED_DATA" \
  build > "$LOG_DIR/screenshots-build.log" 2>&1

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/GlowMate.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "App not found at $APP_PATH"
  exit 1
fi

UDID="$(xcrun simctl list devices available --json | DEVICE_NAME="$DEVICE_NAME" OS_VERSION="$OS_VERSION" python3 -c '
import json, os, sys
name = os.environ["DEVICE_NAME"]
os_version = os.environ["OS_VERSION"]
data = json.load(sys.stdin)
runtime_suffix = "iOS-" + os_version.replace(".", "-")
for runtime, devices in data.get("devices", {}).items():
    if not runtime.endswith(runtime_suffix):
        continue
    for device in devices:
        if device.get("name") == name and device.get("isAvailable"):
            print(device.get("udid", ""))
            raise SystemExit
')"

if [[ -z "$UDID" ]]; then
  echo "Simulator not found: $DEVICE_NAME iOS $OS_VERSION"
  exit 1
fi

xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl ui "$UDID" appearance light >/dev/null || true
xcrun simctl install "$UDID" "$APP_PATH"

validate_png() {
  python3 - "$1" <<'PY'
import struct, sys, zlib
path = sys.argv[1]
with open(path, "rb") as f:
    data = f.read()
if data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit(f"{path}: not a PNG")
pos = 8
width = height = None
idat = []
while pos < len(data):
    length = struct.unpack(">I", data[pos:pos+4])[0]
    chunk_type = data[pos+4:pos+8]
    chunk = data[pos+8:pos+8+length]
    pos += 12 + length
    if chunk_type == b"IHDR":
        width, height = struct.unpack(">II", chunk[:8])
        bit_depth, color_type = chunk[8], chunk[9]
        channels = {0:1, 2:3, 3:1, 4:2, 6:4}[color_type]
    elif chunk_type == b"IDAT":
        idat.append(chunk)
if width is None or not idat:
    raise SystemExit(f"{path}: missing image data")
raw = zlib.decompress(b"".join(idat))
bpp = channels * bit_depth // 8
stride = width * bpp
rows = []
i = 0
for _ in range(height):
    filter_type = raw[i]
    i += 1
    row = bytearray(raw[i:i+stride])
    i += stride
    prev = rows[-1] if rows else bytearray(stride)
    for x in range(stride):
        left = row[x-bpp] if x >= bpp else 0
        up = prev[x]
        up_left = prev[x-bpp] if x >= bpp else 0
        if filter_type == 1:
            row[x] = (row[x] + left) & 255
        elif filter_type == 2:
            row[x] = (row[x] + up) & 255
        elif filter_type == 3:
            row[x] = (row[x] + ((left + up) // 2)) & 255
        elif filter_type == 4:
            p = left + up - up_left
            pa, pb, pc = abs(p-left), abs(p-up), abs(p-up_left)
            pr = left if pa <= pb and pa <= pc else up if pb <= pc else up_left
            row[x] = (row[x] + pr) & 255
    rows.append(row)
sample = []
step_y = max(1, height // 12)
step_x = max(1, width // 12)
for y in range(0, height, step_y):
    row = rows[y]
    for x in range(0, width, step_x):
        offset = x * bpp
        sample.extend(row[offset:offset+min(3, bpp)])
if len(set(sample)) < 8:
    raise SystemExit(f"{path}: image appears blank")
print(f"{path}: {width}x{height} OK")
PY
}

screens=(meter light scenes records settings)

for screen in "${screens[@]}"; do
  echo "Capturing $screen..."
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  launch_output="$(xcrun simctl launch "$UDID" "$BUNDLE_ID" --glowmate-screenshots --glowmate-screen "$screen")"
  echo "$launch_output"
  if ! grep -qE '^[^:]+: [0-9]+' <<< "$launch_output"; then
    echo "Launch did not return a process id for $screen"
    exit 1
  fi
  output="$OUT_DIR/${screen}.png"
  captured=0
  for attempt in {1..14}; do
    sleep 1
    xcrun simctl io "$UDID" screenshot "$output.tmp.png" >/dev/null
    if validate_png "$output.tmp.png" >/dev/null 2>&1; then
      mv "$output.tmp.png" "$output"
      validate_png "$output"
      captured=1
      break
    fi
    echo "  waiting for rendered UI ($attempt/14)"
  done
  rm -f "$output.tmp.png"
  if [[ "$captured" != "1" ]]; then
    echo "Failed to capture rendered UI for $screen"
    exit 1
  fi
done

echo "Screenshots written to $OUT_DIR"
