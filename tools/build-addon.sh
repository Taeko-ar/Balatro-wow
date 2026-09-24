#!/bin/bash
set -e
cd "$(dirname "$0")/.."
ADDON_DIR="$1"
[ -n "$ADDON_DIR" ] || { echo "usage: tools/build-addon.sh <AddOns/Balatro dir>" >&2; exit 1; }

if command -v magick >/dev/null 2>&1; then
    CONVERT="magick"; IDENTIFY="magick identify"
else
    CONVERT="convert"; IDENTIFY="identify"
fi

tools/build-engine.sh
mkdir -p "$ADDON_DIR"
KEEP="Balatro.toc LICENSE Build Core Data Game Runtime UI Assets"
for entry in "$ADDON_DIR"/* "$ADDON_DIR"/.[!.]*; do
    [ -e "$entry" ] || continue
    case " $KEEP " in *" $(basename "$entry") "*) ;; *) rm -rf "$entry" ;; esac
done
for entry in Balatro.toc LICENSE Build Core Data Game Runtime UI; do
    rsync -a --delete "$entry" "$ADDON_DIR/"
done
rsync -a --delete Assets/ "$ADDON_DIR/Assets/"

DIMS="$ADDON_DIR/Runtime/ImageDimensions.lua"
echo "BalatroImageDimensions = {}" > "$DIMS"
find "$ADDON_DIR/Assets" -type f -name "*.png" | sort | while read -r img; do
    w=$($IDENTIFY -format "%w" "$img")
    h=$($IDENTIFY -format "%h" "$img")
    pw=1; while [ $pw -lt "$w" ]; do pw=$((pw * 2)); done
    ph=1; while [ $ph -lt "$h" ]; do ph=$((ph * 2)); done
    tga="${img%.png}.tga"
    $CONVERT "$img" -background transparent -gravity NorthWest -extent ${pw}x${ph} -orient TopLeft -type TrueColorAlpha "$tga"
    rel=$(echo "$tga" | sed "s|^$ADDON_DIR/||; s|/|\\\\\\\\|g")
    echo "BalatroImageDimensions[\"Interface\\\\AddOns\\\\Balatro\\\\$rel\"] = {$w, $h, $pw, $ph}" >> "$DIMS"
    rm "$img"
done

echo "Built addon in $ADDON_DIR"
