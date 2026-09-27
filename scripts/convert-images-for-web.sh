#!/usr/bin/env bash
# Create web-ready JPEG copies from the images directly inside a content folder.
#
# Usage:
#   scripts/convert-images-for-web.sh <source-directory> [output-directory]
#
# Defaults: output-directory is <source-directory>/img, MAX_PIXELS is 2400, and
# JPEG_QUALITY is 82. Example:
#   scripts/convert-images-for-web.sh content/posts/devopsdayskc-2024
#
# Potential image-optimization candidates found in this repository (largest first):
#   content/posts/electrifying-berg-tractor
#   content/posts/devopsdayskc-2024/img
#   static/slides/systems-thinking/img       # Review individually: diagrams may need PNG.
#   static/slides/diagramming-as-code/img    # Review individually: diagrams may need PNG.
#   content/posts/kcdc-2025-recap
#   content/posts/qcon-sf-2019-recap
#   static/img                    # Review individually: icons/diagrams may need PNG.
#   content/posts/learning-with-preschoolers
#   content/posts/kcdc-2026-recap
#   content/talks/diagnose-your-lethargic-jvm
#   content/posts/communitydays-kc-2026
#   content/posts/kcdc-2021-recap
#   content/posts/bluebird-house
#   content/talks/tend-to-your-o11y-garden
#   content/posts/learning-through-repair-spa
#   content/talks/heap-space-nine
#   content/posts/drawing-101
#   content/posts/defrag-your-calendar
#   content/talks/hitchhikers-guide-to-meetings-virtual-edition-guide
#   content/posts/visualize-progress-through-contrast
#   content/talks/building-conf-healthcare-through-chaos-eng
#   content/posts/decisions-the-pursuit-of-options
#
# This script uses macOS `sips` and does not modify source images. It writes JPEGs
# only; use it for photos, not graphics that require transparency or crisp text.

set -euo pipefail

source_dir="${1:-}"
if [[ -z "$source_dir" || ! -d "$source_dir" ]]; then
  echo "Usage: $0 <source-directory> [output-directory]" >&2
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "This script requires macOS sips." >&2
  exit 1
fi

output_dir="${2:-$source_dir/img}"
max_pixels="${MAX_PIXELS:-2400}"
jpeg_quality="${JPEG_QUALITY:-82}"

if ! [[ "$max_pixels" =~ ^[0-9]+$ && "$jpeg_quality" =~ ^[0-9]+$ ]] || (( jpeg_quality < 1 || jpeg_quality > 100 )); then
  echo "MAX_PIXELS must be a positive integer and JPEG_QUALITY must be 1-100." >&2
  exit 1
fi

mkdir -p "$output_dir"

converted=0
skipped=0
while IFS= read -r -d '' file; do
  filename="${file##*/}"
  destination="$output_dir/${filename%.*}.jpg"

  if [[ -e "$destination" ]]; then
    echo "Skipping existing file: $destination" >&2
    ((skipped += 1))
    continue
  fi

  sips -Z "$max_pixels" -s format jpeg -s formatOptions "$jpeg_quality" "$file" --out "$destination" >/dev/null
  echo "Created: $destination"
  ((converted += 1))
done < <(find "$source_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)

echo "Converted $converted image(s); skipped $skipped existing output(s)."
