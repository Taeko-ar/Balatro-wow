#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
mkdir -p Build
OUT="Build/Engine.lua"
echo "BALATRO_MODULES = {}" > "$OUT"
find Engine -name "*.lua" | sort | while read -r filepath; do
    modname=$(echo "$filepath" | sed 's|^Engine/||; s|\.lua$||')
    {
        echo "BALATRO_MODULES[\"$modname\"] = [==["
        cat "$filepath"
        echo "]==]"
    } >> "$OUT"
done
echo "Built $OUT"
