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
compare_previous_report="$(mktemp)"
compare_json_report="$(mktemp)"
compare_markdown_report="$(mktemp)"
runtime_json_report="$(mktemp)"
runtime_markdown_report="$(mktemp)"
runtime_unsupported_report="$(mktemp)"
symlink_home="$(mktemp -d)"
trap 'rm -f "$markdown_report" "$json_report" "$invalid_doctor_report" "$valid_doctor_report" "$compare_previous_report" "$compare_json_report" "$compare_markdown_report" "$runtime_json_report" "$runtime_markdown_report" "$runtime_unsupported_report" "$FAKE_CODEX_LOG"; rm -rf "$symlink_home"' EXIT

test "$("$ROOT_DIR/bin/codex-healthkit" --version)" = "codex-healthkit 0.2.0"

CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check >"$markdown_report"

grep -q "auth files read: \`no\`" "$markdown_report"
grep -q "SQLite contents read: \`no\`" "$markdown_report"
demo_sources=(
  "$ROOT_DIR/assets/source/terminal-demo.svg"
  "$ROOT_DIR/assets/source/terminal-demo-compare.svg"
  "$ROOT_DIR/assets/source/terminal-demo-boundary.svg"
)
grep -q 'width="1200" height="675"' "${demo_sources[@]}"
grep -q 'fixture-only demo' "${demo_sources[@]}"
if grep -Eq '/Users/|/home/|auth\\.json|token\\.json|BEGIN .*PRIVATE KEY' \
  "${demo_sources[@]}"; then
  exit 1
fi

CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$json_report"

grep -q '"tool": "codex-healthkit"' "$json_report"
grep -q '"auth_files_read": false' "$json_report"
grep -q '"requested": false' "$json_report"

CODEX_HEALTHKIT_TEST_OS=Darwin \
  CODEX_HEALTHKIT_TEST_EPOCH=1784592000 \
  CODEX_HEALTHKIT_TEST_RUNTIME_DIR="$ROOT_DIR/tests/fixtures/runtime-macos" \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --with-runtime --json >"$runtime_json_report"

CODEX_HEALTHKIT_TEST_OS=Darwin \
  CODEX_HEALTHKIT_TEST_EPOCH=1784592000 \
  CODEX_HEALTHKIT_TEST_RUNTIME_DIR="$ROOT_DIR/tests/fixtures/runtime-macos" \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --with-runtime >"$runtime_markdown_report"

CODEX_HEALTHKIT_TEST_OS=Linux \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --with-runtime --json >"$runtime_unsupported_report"

grep -q 'Optional macOS Runtime Metadata' "$runtime_markdown_report"
grep -q 'No process is stopped or cleaned up' "$runtime_markdown_report"

if command -v jq >/dev/null 2>&1; then
  jq empty "$ROOT_DIR/schemas/runtime-diagnostics-v0.1.schema.json"
  jq empty "$json_report"
  jq -e '
    .summary.status == "watch" and
    .runtime.requested == true and
    .runtime.supported == true and
    .runtime.memory.free_percent == 9 and
    .runtime.memory.swap_used_mib == 9000 and
    .runtime.processes.codex_renderer.count == 2 and
    .runtime.processes.codex_renderer.rss_bytes == 189440000 and
    .runtime.processes.computer_use_client.count == 12 and
    .runtime.processes.computer_use_client.orphan_candidate_count == 1 and
    .runtime.processes.computer_use_service.long_running_count == 1 and
    .runtime.processes.computer_use_service.ppid_init_candidate_count == 1 and
    .runtime.processes.computer_use_service.parent_missing_candidate_count == 0 and
    .runtime.processes.computer_use_service.residual_candidate_count == 1 and
    .runtime.processes.computer_use_service.items[0].parent_state == "init" and
    .runtime.processes.computer_use_client.items[1].parent_state == "missing" and
    .runtime.processes.playwright_worker.count == 1 and
    ([.runtime.processes[].items[]? | has("category")] | any | not) and
    .safety.process_arguments_read == false and
    .safety.process_environment_read == false and
    .safety.process_open_files_read == false
  ' "$runtime_json_report" >/dev/null

  jq -e '
    .summary.status == "ok" and
    .runtime.requested == true and
    .runtime.supported == false and
    .runtime.status == "unsupported" and
    (.runtime.note | contains("existing checks continued"))
  ' "$runtime_unsupported_report" >/dev/null

  jq '
    .generated_at = "2026-07-21T00:00:00Z" |
    .runtime.processes.codex_renderer.items = [
      {"pid": 190, "started_at_epoch": 1784580000},
      {"pid": 191, "started_at_epoch": 1784580060}
    ] |
    .runtime.processes.computer_use_client.count = 1 |
    .runtime.processes.playwright_worker.count = 0
  ' "$runtime_json_report" >"$compare_previous_report"

  CODEX_HEALTHKIT_TEST_OS=Darwin \
    CODEX_HEALTHKIT_TEST_EPOCH=1784592000 \
    CODEX_HEALTHKIT_TEST_RUNTIME_DIR="$ROOT_DIR/tests/fixtures/runtime-macos" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --with-runtime --json --compare "$compare_previous_report" >"$compare_json_report"

  jq -e '
    .comparison.items.runtime.available == true and
    .comparison.items.runtime.codex_renderer.started_count == 2 and
    .comparison.items.runtime.codex_renderer.exited_count == 2 and
    .comparison.items.runtime.codex_renderer.churn_candidate == true and
    .comparison.items.runtime.computer_use_client_count.delta_count == 11 and
    .comparison.items.runtime.computer_use_client_count.growth_candidate == true and
    .comparison.items.runtime.playwright_worker_count.delta_count == 1 and
    .comparison.items.runtime.playwright_worker_count.growth_candidate == false
  ' "$compare_json_report" >/dev/null

  jq '
    .generated_at = "2026-07-01T00:00:00Z" |
    .state.logs_2_sqlite_wal.bytes = 1024 |
    .state.logs_2_sqlite.bytes = 2048 |
    .state.sessions.bytes = 100 |
    .state.sessions.jsonl_count = 1 |
    .state.archived_sessions.bytes = 10 |
    .state.archived_sessions.jsonl_count = 0 |
    .state.quarantine.bytes = 0
  ' "$json_report" >"$compare_previous_report"

  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json --compare "$compare_previous_report" >"$compare_json_report"

  jq -e '
    .comparison.requested == true and
    .comparison.loaded == true and
    .comparison.previous_generated_at == "2026-07-01T00:00:00Z" and
    .comparison.items.logs_2_sqlite_wal.delta_bytes == (.comparison.items.logs_2_sqlite_wal.current_bytes - .comparison.items.logs_2_sqlite_wal.previous_bytes) and
    .comparison.items.sessions_jsonl_count.delta_count == (.comparison.items.sessions_jsonl_count.current_count - .comparison.items.sessions_jsonl_count.previous_count) and
    .comparison.items.archived_sessions_jsonl_count.direction == "unchanged" and
    (.comparison.note | contains("informational"))
  ' "$compare_json_report" >/dev/null

  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --compare "$compare_previous_report" >"$compare_markdown_report"

  grep -q "Previous Report Comparison" "$compare_markdown_report"
  grep -q "logs_2.sqlite-wal" "$compare_markdown_report"
  grep -q "archived sessions" "$compare_markdown_report"
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
