#!/bin/bash

# Run as:
# > ./canon_copy.sh /Volumes/EOS_DIGITAL/ /Volumes/MyPassport-NEW-ARCHIVE/CANADA_photos/
#
# Copies DCIM/*CANON/* into TARGET/YYYY/YYYY-MM-DD/ by file mtime.

set -euo pipefail
set -C
shopt -s nullglob

if [[ $# -ne 2 ]]; then
  echo "usage: $0 SOURCE TARGET" >&2
  exit 1
fi

SOURCE="${1%/}"
TARGET="${2%/}"
CANONS="$SOURCE/DCIM"

[[ -d "$CANONS" ]] || { echo "no DCIM folder in '$SOURCE'" >&2; exit 1; }
[[ -d "$TARGET" ]] || { echo "target '$TARGET' does not exist" >&2; exit 1; }

for FILE in "$CANONS"/*CANON/*; do
  [[ -f "$FILE" ]] || continue
  DATE=$(stat -f %Sm -t "%Y-%m-%d" "$FILE")
  YEAR=${DATE:0:4}
  mkdir -p "$TARGET/$YEAR/$DATE"
  echo "$FILE -> $TARGET/$YEAR/$DATE"
  cp -a -f "$FILE" "$TARGET/$YEAR/$DATE"
done
