#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_HOME="$ROOT_DIR/tests/fixtures/codex-home"
FAKE_BIN="$ROOT_DIR/tests/fixtures/fake-bin"
FAKE_CODEX_LOG="$ROOT_DIR/tests/fixtures/fake-codex.log"

markdown_report="$(mktemp)"
json_report="$(mktemp)"
invalid_doctor_report="$(mktemp)"
valid_doctor_report="$(mktemp)"
symlink_home="$(mktemp -d)"
trap 'rm -f "$markdown_report" "$json_report" "$invalid_doctor_report" "$valid_doctor_report" "$FAKE_CODEX_LOG"; rm -rf "$symlink_home"' EXIT

CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check >"$markdown_report"

grep -q "auth files read: \`no\`" "$markdown_report"
grep -q "SQLite contents read: \`no\`" "$markdown_report"

CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$json_report"

grep -q '"tool": "codex-healthkit"' "$json_report"
grep -q '"auth_files_read": false' "$json_report"

if command -v jq >/dev/null 2>&1; then
  jq empty "$json_report"
fi

rm -f "$FAKE_CODEX_LOG"
PATH="$FAKE_BIN:$PATH" FAKE_CODEX_LOG="$FAKE_CODEX_LOG" \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$json_report"
test ! -e "$FAKE_CODEX_LOG"

PATH="$FAKE_BIN:$PATH" CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --with-codex-doctor --json >"$invalid_doctor_report"

if command -v jq >/dev/null 2>&1; then
  jq -e '.official_codex_doctor.status == "error"' "$invalid_doctor_report" >/dev/null
fi

PATH="$FAKE_BIN:$PATH" FAKE_CODEX_DOCTOR_MODE=valid \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --with-codex-doctor --json >"$valid_doctor_report"

if command -v jq >/dev/null 2>&1; then
  jq -e '
    .summary.status == "fail" and
    .official_codex_doctor.status == "fail" and
    .official_codex_doctor.ok == 1 and
    .official_codex_doctor.warn == 2 and
    .official_codex_doctor.fail == 2 and
    (.official_codex_doctor.note | contains("raw output not included"))
  ' "$valid_doctor_report" >/dev/null
fi

if grep -q 'doctor-ok' "$valid_doctor_report"; then
  exit 1
fi

ln -s "$FIXTURE_HOME/sessions" "$symlink_home/sessions"
CODEX_HOME="$symlink_home" CODEX_SQLITE_HOME="$symlink_home" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$json_report"

if command -v jq >/dev/null 2>&1; then
  jq -e '.state.sessions.exists == false and .state.sessions.jsonl_count == 0' "$json_report" >/dev/null
fi

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$ROOT_DIR/bin/codex-healthkit" "$ROOT_DIR/tests/run.sh" "$FAKE_BIN/codex"
fi

printf 'tests ok\n'
