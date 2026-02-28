#!/usr/bin/env bash
set -euo pipefail

MOD_NAME="FS25_EngineSoundsPreview"
OUT_ZIP="${1:-${MOD_NAME}.zip}"

rm -f "$OUT_ZIP"
zip -r "$OUT_ZIP" modDesc.xml inputBinding.xml l10n scripts -x "*.DS_Store" >/dev/null

echo "Created $OUT_ZIP"
echo "Install by copying $OUT_ZIP into your Farming Simulator 25 mods folder."
