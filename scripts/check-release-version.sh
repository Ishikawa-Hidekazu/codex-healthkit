#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPECTED_TAG="${1:-}"

if ! printf '%s' "$EXPECTED_TAG" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  printf 'usage: %s vMAJOR.MINOR.PATCH\n' "$0" >&2
  exit 2
fi

PACKAGE_VERSION="$(awk -F '"' '/^version = "[0-9]+\.[0-9]+\.[0-9]+"$/ { print $2; exit }' "$ROOT_DIR/pyproject.toml")"
CLI_VERSION="$(sed -n 's/^VERSION="\([0-9][0-9.]*\)"$/\1/p' "$ROOT_DIR/bin/codex-healthkit")"
EXPECTED_VERSION="${EXPECTED_TAG#v}"

test -n "$PACKAGE_VERSION"
test -n "$CLI_VERSION"
test "$PACKAGE_VERSION" = "$EXPECTED_VERSION"
test "$CLI_VERSION" = "$EXPECTED_VERSION"
test -f "$ROOT_DIR/docs/releases/$EXPECTED_TAG.md"
grep -q "^## $EXPECTED_VERSION - " "$ROOT_DIR/CHANGELOG.md"
grep -q -- "--branch $EXPECTED_TAG --depth 1" "$ROOT_DIR/README.md"
grep -q -- "--branch $EXPECTED_TAG --depth 1" "$ROOT_DIR/README.ja.md"

printf 'release versions aligned: %s\n' "$EXPECTED_TAG"
