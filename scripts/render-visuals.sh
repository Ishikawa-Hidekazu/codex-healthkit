#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v resvg >/dev/null 2>&1; then
  printf 'resvg 0.47 or newer is required to render repository visuals.\n' >&2
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  printf 'ImageMagick 7 (magick command) is required to verify repository visuals.\n' >&2
  exit 1
fi

resvg "$ROOT_DIR/assets/source/health-report-overview.svg" \
  "$ROOT_DIR/assets/health-report-overview.png"
resvg "$ROOT_DIR/assets/source/health-report-mobile.svg" \
  "$ROOT_DIR/assets/health-report-mobile.png"
resvg "$ROOT_DIR/assets/source/social-preview.svg" \
  "$ROOT_DIR/assets/social-preview.png"

check_image() {
  local file="$1"
  local expected="$2"
  local dimensions bytes
  dimensions="$(magick identify -format '%wx%h' "$file")"
  bytes="$(wc -c <"$file" | tr -d ' ')"
  if [ "$dimensions" != "$expected" ] || [ "$bytes" -gt 500000 ]; then
    printf 'Unexpected visual output: %s (%s, %s bytes)\n' "$file" "$dimensions" "$bytes" >&2
    exit 1
  fi
}

check_image "$ROOT_DIR/assets/health-report-overview.png" "1200x960"
check_image "$ROOT_DIR/assets/health-report-mobile.png" "750x1200"
check_image "$ROOT_DIR/assets/social-preview.png" "1280x640"

printf 'Rendered fixture-only visuals in assets/.\n'
