#!/usr/bin/env bash
# Render the boot splash images in theme/ from mark-signal.svg (the Grounded alien mark).
#   ./splash/build.sh        (needs rsvg-convert, from librsvg)
# The mark's path is six subpaths: the head and its two eyes, then the three ground bars.
# Each part is rendered on the full 120x120 canvas, so the layers line up when stacked.
# Re-run after replacing mark-signal.svg, then commit the PNGs.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$DIR/theme"
SIZES=(160 224 288 448)         # mark heights in px; the theme picks one by screen height
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

d=$(sed -n 's/.* d="\([^"]*\)".*/\1/p' "$DIR/mark-signal.svg")
fill=$(sed -n 's/.*<path fill="\([^"]*\)".*/\1/p' "$DIR/mark-signal.svg")
IFS=M read -ra sub <<<"$d"      # sub[0] is empty: d starts with M
[ "${#sub[@]}" -eq 7 ] || { echo "Expected 6 subpaths in mark-signal.svg, found $((${#sub[@]} - 1))" >&2; exit 1; }

part() {    # part <name> <subpath indexes...>
    local name=$1 path="" i; shift
    for i in "$@"; do path+="M${sub[$i]}"; done
    printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120"><path fill="%s" d="%s"/></svg>' \
        "$fill" "$path" >"$tmp/$name.svg"
}
part head 1 2 3
part bar1 4
part bar2 5
part bar3 6

rm -f "$OUT"/*.png
for size in "${SIZES[@]}"; do
    for name in head bar1 bar2 bar3; do
        rsvg-convert -w "$size" -h "$size" "$tmp/$name.svg" -o "$OUT/$name-$size.png"
    done
done

# Journal panel fill: Grounded `surface` (#1b2124); the theme tiles it to size.
printf '<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"><rect width="8" height="8" fill="#1b2124"/></svg>' >"$tmp/panel.svg"
rsvg-convert "$tmp/panel.svg" -o "$OUT/panel.png"

echo "Rendered $(ls "$OUT"/*.png | wc -l) images into $OUT"
