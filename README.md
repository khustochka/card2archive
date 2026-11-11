# card2archive

Copies photos and videos from a camera card into an archive folder, sorted by date:

    ARCHIVE/2024/2024-07-15/IMG_0001.CR3

## Usage

    ./card2archive.sh [-n|--dry-run] SOURCE TARGET

    ./card2archive.sh --dry-run /Volumes/EOS_DIGITAL /Volumes/ARCHIVE/Photos
    ./card2archive.sh /Volumes/EOS_DIGITAL /Volumes/ARCHIVE/Photos

`TARGET` must exist; year and date folders are created as needed.

## Behaviour

- Reads all DCF folders on the card (`DCIM/100CANON`, `100NIKON`, `100MSDCF`, …).
- Date is the file's modification time, as set by the camera.
- Files already in the archive are skipped. A same-named file with a different
  size is reported as a **conflict** and not copied.
- Copies go to a hidden `.NAME.part` file and are renamed when complete, so an
  interrupted run is safe to re-run. Leftovers can be removed with
  `find TARGET -name '.*.part' -delete`.

## Requirements and limits

- macOS (uses BSD `stat`).
- Video stored outside `DCIM` (Sony `PRIVATE/M4ROOT`, AVCHD) is not copied.
