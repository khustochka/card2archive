#!/bin/bash

# Run as:
# > ./canon_copy.sh [-n|--dry-run] /Volumes/EOS_DIGITAL/ /Volumes/MyPassport-NEW-ARCHIVE/CANADA_photos/
#
# Copies DCIM/*CANON/* into TARGET/YYYY/YYYY-MM-DD/ by file mtime.
# -n, --dry-run: show what would be copied or skipped without writing anything.
#
# Files already in the target are skipped; a skipped file whose size differs
# from the existing one is flagged as a CONFLICT (likely a name clash). Each
# copy is written to a hidden .NAME.part file and renamed when complete, so an
# interrupted run never leaves a truncated file under its final name; just
# re-run it.

set -euo pipefail
set -C
shopt -s nullglob

usage() {
  echo "usage: $0 [-n|--dry-run] SOURCE TARGET" >&2
  exit 1
}

DRY_RUN=0
if [[ ${1:-} == "-n" || ${1:-} == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi
[[ $# -eq 2 ]] || usage

SOURCE="${1%/}"
TARGET="${2%/}"
CANONS="$SOURCE/DCIM"

[[ -d "$CANONS" ]] || { echo "no DCIM folder in '$SOURCE'" >&2; exit 1; }
[[ -d "$TARGET" ]] || { echo "target '$TARGET' does not exist" >&2; exit 1; }

FILES=("$CANONS"/*CANON/*)
TOTAL=${#FILES[@]}
if (( TOTAL == 0 )); then
  echo "no files found in $CANONS/*CANON/"
  exit 0
fi

(( DRY_RUN )) && echo "DRY RUN: nothing will be written"
echo "$SOURCE -> $TARGET ($TOTAL files)"

COPIED=0
SKIPPED=0
CONFLICTS=0
CONFLICT_LIST=()
I=0

for FILE in "${FILES[@]}"; do
  I=$((I + 1))
  [[ -f "$FILE" ]] || continue
  DATE=$(stat -f %Sm -t "%Y-%m-%d" "$FILE")
  YEAR=${DATE:0:4}
  REL_DEST="$YEAR/$DATE"
  DEST="$TARGET/$REL_DEST"
  NAME=$(basename "$FILE")
  REL_SRC="${FILE#"$CANONS"/}"
  PREFIX=$(printf "[%*d/%d]" ${#TOTAL} "$I" "$TOTAL")

  if [[ -e "$DEST/$NAME" ]]; then
    if [[ $(stat -f %z "$FILE") == $(stat -f %z "$DEST/$NAME") ]]; then
      echo "$PREFIX skip      $REL_SRC (already in $REL_DEST/)"
      SKIPPED=$((SKIPPED + 1))
    else
      echo "$PREFIX CONFLICT  $REL_SRC (different file with same name in $REL_DEST/, not copied)"
      CONFLICTS=$((CONFLICTS + 1))
      CONFLICT_LIST+=("$REL_SRC vs $REL_DEST/$NAME")
    fi
    continue
  fi

  echo "$PREFIX copy      $REL_SRC -> $REL_DEST/"
  COPIED=$((COPIED + 1))
  (( DRY_RUN )) && continue
  mkdir -p "$DEST"
  cp -a -f "$FILE" "$DEST/.$NAME.part"
  mv "$DEST/.$NAME.part" "$DEST/$NAME"
done

echo
if (( DRY_RUN )); then
  echo "Dry run: $COPIED to copy, $SKIPPED already present, $CONFLICTS conflicts."
else
  echo "Done: $COPIED copied, $SKIPPED already present, $CONFLICTS conflicts."
fi
if (( CONFLICTS )); then
  echo "Conflicts (not copied, check manually):"
  printf '  %s\n' "${CONFLICT_LIST[@]}"
fi
