#!/bin/bash
set -e
cd "$(dirname "$0")/.."
VERSION="${1:-$(sed -n 's/^## Version: //p' Balatro.toc)}"
rm -rf dist
tools/build-addon.sh dist/Balatro
sed -i "s/^## Version: .*/## Version: ${VERSION#v}/" dist/Balatro/Balatro.toc
(cd dist && zip -qr "Balatro-${VERSION#v}.zip" Balatro)
echo "dist/Balatro-${VERSION#v}.zip"
