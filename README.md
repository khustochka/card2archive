# card2archive

Copies photos and videos from a camera card into an archive folder, sorted by date:

    ARCHIVE/2024/2024-07-15/IMG_0001.CR3

## Usage

    ./card2archive.sh [-n|--dry-run] SOURCE TARGET

    ./card2archive.sh --dry-run /Volumes/EOS_DIGITAL /Volumes/ARCHIVE/Photos
    ./card2archive.sh /Volumes/EOS_DIGITAL /Volumes/ARCHIVE/Photos

`TARGET` must exist; year and date folders are created as needed.

For long copies, prevent the Mac and drives from sleeping mid-run (which can
stall the copy) with `caffeinate -ims ./card2archive.sh SOURCE TARGET`.
`-s` only applies on power, and closing the lid still sleeps the Mac.

## Behaviour

- Reads all DCF folders on the card (`DCIM/100CANON`, `100NIKON`, `100MSDCF`, …).
- Date is the file's modification time, as set by the camera.
- Files already in the archive are skipped. A same-named file with a different
  size is reported as a **conflict** and not copied.
- Copies go to a hidden `.NAME.part` file and are renamed when complete, so an
  interrupted run is safe to re-run. Leftovers can be removed with
  `find TARGET -name '.*.part' -delete`.

## Backing up the archive to a second drive

Use rsync 3.x (`brew install rsync`); the one bundled with macOS is outdated.

    caffeinate -ims rsync -a --info=progress2 --itemize-changes \
      --exclude='.*.part' --exclude='.DS_Store' \
      /Volumes/ARCHIVE/Photos/ /Volumes/ARCHIVE2/Photos/

- Add `-n` first for a dry run.
- `caffeinate -ims` keeps the Mac and drives awake until rsync finishes. If a
  run stalls anyway, Ctrl-C and re-run; completed files are skipped.
- `--itemize-changes` lists each copied file with a change code:
  `>f+++++++++` is a new file, `>f.st......` one whose size or time changed.
- Keep the trailing `/` on the source, or you get `Photos/Photos/`.
- Extended attributes (Finder tags, `com.apple.*` metadata) are not copied;
  add `-X` to include them.
- `--delete` is left out on purpose: it would also remove files deleted by
  mistake from the main archive. To mirror deletions safely, add
  `--delete --backup --backup-dir=/Volumes/ARCHIVE2/_deleted/$(date +%F)`.
- To verify contents occasionally (slow, reads every file):
  `rsync -anc --itemize-changes SRC/ DST/`.

## Requirements and limits

- macOS (uses BSD `stat`).
- Video stored outside `DCIM` (Sony `PRIVATE/M4ROOT`, AVCHD) is not copied.
