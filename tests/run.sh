#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_HOME="$ROOT_DIR/tests/fixtures/codex-home"
FAKE_BIN="$ROOT_DIR/tests/fixtures/fake-bin"
FAKE_DATE_BIN="$ROOT_DIR/tests/fixtures/fake-date-bin"
FAKE_CODEX_LOG="$ROOT_DIR/tests/fixtures/fake-codex.log"

markdown_report="$(mktemp)"
json_report="$(mktemp)"
invalid_doctor_report="$(mktemp)"
valid_doctor_report="$(mktemp)"
compare_previous_report="$(mktemp)"
compare_json_report="$(mktemp)"
compare_markdown_report="$(mktemp)"
advisory_previous_report="$(mktemp)"
advisory_json_report="$(mktemp)"
default_summary_report="$(mktemp)"
update_json_report="$(mktemp)"
update_markdown_report="$(mktemp)"
symlink_home="$(mktemp -d)"
session_count_home="$(mktemp -d)"
session_count_report="$(mktemp)"
FAKE_CURL_LOG="$ROOT_DIR/tests/fixtures/fake-curl.log"
trap 'rm -f "$markdown_report" "$json_report" "$invalid_doctor_report" "$valid_doctor_report" "$compare_previous_report" "$compare_json_report" "$compare_markdown_report" "$advisory_previous_report" "$advisory_json_report" "$default_summary_report" "$update_json_report" "$update_markdown_report" "$session_count_report" "$FAKE_CODEX_LOG" "$FAKE_CURL_LOG"; rm -rf "$symlink_home" "$session_count_home"' EXIT

test "$("$ROOT_DIR/bin/codex-healthkit" --version)" = "codex-healthkit 0.4.1"

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

first_run_template="$ROOT_DIR/.github/ISSUE_TEMPLATE/04-first-run-report.yml"
grep -q '^name: First-run report$' "$first_run_template"
grep -q 'including successful runs' "$first_run_template"
grep -q 'Do not attach a raw health report' "$first_run_template"
grep -q 'SQLite contents' "$first_run_template"
grep -q 'session transcripts' "$first_run_template"
grep -q 'uvx temporary run' "$first_run_template"
grep -q 'uv tool install' "$first_run_template"
grep -q 'pipx install' "$first_run_template"
grep -q '04-first-run-report.yml' "$ROOT_DIR/README.md" "$ROOT_DIR/README.ja.md"
grep -q 'git clone --branch v0.4.1 --depth 1' "$ROOT_DIR/README.md" "$ROOT_DIR/README.ja.md"
grep -q './codex-healthkit/bin/codex-healthkit check' "$ROOT_DIR/README.md" "$ROOT_DIR/README.ja.md"
grep -q 'uvx --from codex-healthkit==0.4.1 codex-healthkit check' "$ROOT_DIR/README.md" "$ROOT_DIR/README.ja.md"
grep -q 'uv tool install codex-healthkit==0.4.1' "$ROOT_DIR/README.md" "$ROOT_DIR/README.ja.md"
"$ROOT_DIR/scripts/check-release-version.sh" v0.4.1 >/dev/null

CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$json_report"

grep -q '"tool": "codex-healthkit"' "$json_report"
grep -q '"auth_files_read": false' "$json_report"

if command -v jq >/dev/null 2>&1; then
  jq empty "$json_report"
  jq -e 'has("codex_update") | not' "$json_report" >/dev/null
  jq -e '.state.sessions.session_file_count == .state.sessions.jsonl_count' "$json_report" >/dev/null
  current_sessions_bytes="$(jq -r '.state.sessions.bytes' "$json_report")"
  previous_growth_bytes=1024
  expected_daily_growth=$(((current_sessions_bytes - previous_growth_bytes) * 2))

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

  jq -e '.comparison | has("advisory") | not' "$compare_json_report" >/dev/null
  jq '.summary' "$compare_json_report" >"$default_summary_report"

  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --compare "$compare_previous_report" >"$compare_markdown_report"

  grep -q "Previous Report Comparison" "$compare_markdown_report"
  grep -q "logs_2.sqlite-wal" "$compare_markdown_report"
  grep -q "archived sessions" "$compare_markdown_report"

  jq '
    .generated_at = "2026-08-01T12:00:00Z" |
    .state.sessions.bytes = $previous_bytes
  ' --argjson previous_bytes "$previous_growth_bytes" "$json_report" >"$advisory_previous_report"

  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json \
      --compare "$advisory_previous_report" \
      --sessions-total-advisory-bytes "$current_sessions_bytes" \
      --sessions-daily-growth-advisory-bytes "$expected_daily_growth" >"$advisory_json_report"

  jq -e --argjson current_bytes "$current_sessions_bytes" --argjson previous_bytes "$previous_growth_bytes" --argjson expected_growth "$expected_daily_growth" '
    .comparison.interval.valid == true and
    .comparison.interval.seconds == 43200 and
    .comparison.sessions_growth.delta_bytes == ($current_bytes - $previous_bytes) and
    .comparison.sessions_growth.bytes_per_day == $expected_growth and
    .comparison.advisory.triggered == true and
    .comparison.advisory.reasons == ["large_total", "rapid_growth"] and
    .comparison.advisory.thresholds.sessions_total_bytes == $current_bytes and
    .comparison.advisory.thresholds.sessions_daily_growth_bytes == $expected_growth
  ' "$advisory_json_report" >/dev/null
  test "$(jq -c '.summary' "$advisory_json_report")" = "$(jq -c '.' "$default_summary_report")"

  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json \
      --compare "$advisory_previous_report" \
      --sessions-total-advisory-bytes "$((current_sessions_bytes + 1))" \
      --sessions-daily-growth-advisory-bytes "$expected_daily_growth" >"$advisory_json_report"
  jq -e '.comparison.advisory.reasons == ["rapid_growth"]' "$advisory_json_report" >/dev/null

  jq '.state.sessions.bytes = $current_bytes' --argjson current_bytes "$current_sessions_bytes" \
    "$advisory_previous_report" >"$compare_previous_report"
  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json \
      --compare "$compare_previous_report" \
      --sessions-daily-growth-advisory-bytes 1 >"$advisory_json_report"
  jq -e '
    .comparison.sessions_growth.bytes_per_day == 0 and
    .comparison.advisory.triggered == false
  ' "$advisory_json_report" >/dev/null

  jq '.state.sessions.bytes = ($current_bytes + 4096)' --argjson current_bytes "$current_sessions_bytes" \
    "$advisory_previous_report" >"$compare_previous_report"
  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json \
      --compare "$compare_previous_report" \
      --sessions-daily-growth-advisory-bytes 1 >"$advisory_json_report"
  jq -e '
    .comparison.sessions_growth.bytes_per_day == -8192 and
    .comparison.advisory.triggered == false
  ' "$advisory_json_report" >/dev/null

  jq '
    .generated_at = "2026-07-31T00:00:00Z" |
    .state.sessions.bytes = 0
  ' "$json_report" >"$compare_previous_report"
  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check --json --compare "$compare_previous_report" >"$advisory_json_report"
  jq -e --argjson expected_growth "$((current_sessions_bytes / 2))" '
    .comparison.interval.seconds == 172800 and
    .comparison.sessions_growth.bytes_per_day == $expected_growth and
    (.comparison | has("advisory") | not)
  ' "$advisory_json_report" >/dev/null

  for invalid_timestamp in same invalid; do
    if [ "$invalid_timestamp" = "same" ]; then
      jq '.generated_at = "2026-08-02T00:00:00Z"' "$json_report" >"$compare_previous_report"
    else
      jq '.generated_at = "not-a-timestamp"' "$json_report" >"$compare_previous_report"
    fi
    PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
      CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
      "$ROOT_DIR/bin/codex-healthkit" check --json \
        --compare "$compare_previous_report" \
        --sessions-daily-growth-advisory-bytes 1 >"$advisory_json_report"
    jq -e '
      .comparison.interval.valid == false and
      .comparison.interval.seconds == null and
      .comparison.sessions_growth.bytes_per_day == null and
      .comparison.advisory.triggered == false and
      (.comparison.advisory.note | contains("not evaluated"))
    ' "$advisory_json_report" >/dev/null
  done

  PATH="$FAKE_DATE_BIN:$PATH" FAKE_DATE_NOW="2026-08-02T00:00:00Z" \
    CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
    "$ROOT_DIR/bin/codex-healthkit" check \
      --compare "$advisory_previous_report" \
      --sessions-total-advisory-bytes "$current_sessions_bytes" >"$compare_markdown_report"
  grep -q "comparison_interval: \`43200 seconds\`" "$compare_markdown_report"
  grep -q "Sessions Advisory" "$compare_markdown_report"
  grep -q '"large_total"' "$compare_markdown_report"

  jq empty "$ROOT_DIR/schemas/comparison-v0.2.schema.json"
fi

mkdir -p "$session_count_home/sessions" "$session_count_home/archived_sessions"
: >"$session_count_home/sessions/current.jsonl"
: >"$session_count_home/sessions/current.jsonl.zst"
: >"$session_count_home/sessions/ignored.txt"
: >"$session_count_home/archived_sessions/archived.jsonl"
: >"$session_count_home/archived_sessions/archived.jsonl.zst"
: >"$session_count_home/archived_sessions/ignored.gz"
CODEX_HOME="$session_count_home" CODEX_SQLITE_HOME="$session_count_home" \
  "$ROOT_DIR/bin/codex-healthkit" check --json >"$session_count_report"

if command -v jq >/dev/null 2>&1; then
  jq -e '
    .state.sessions.jsonl_count == 1 and
    .state.sessions.session_file_count == 2 and
    .state.archived_sessions.jsonl_count == 1 and
    .state.archived_sessions.session_file_count == 2
  ' "$session_count_report" >/dev/null
fi

rm -f "$FAKE_CURL_LOG"
PATH="$FAKE_BIN:$PATH" FAKE_CODEX_VERSION=0.147.0 FAKE_LATEST_CODEX_VERSION=0.148.0 \
  FAKE_CURL_LOG="$FAKE_CURL_LOG" CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json --check-latest-codex >"$update_json_report"

if command -v jq >/dev/null 2>&1; then
  jq -e --arg expected_executable "$FAKE_BIN/codex" '
    .codex_cli.version == "codex-cli 0.147.0" and
    .codex_update.requested == true and
    .codex_update.checked == true and
    .codex_update.executable_path == $expected_executable and
    .codex_update.current_version == "0.147.0" and
    .codex_update.latest_version == "0.148.0" and
    .codex_update.update_available == true and
    .summary.status == "ok" and
    .safety.healthkit_network_telemetry == false
  ' "$update_json_report" >/dev/null
fi
grep -q '^-q --proto =https ' "$FAKE_CURL_LOG"
grep -q 'https://registry.npmjs.org/@openai%2Fcodex/latest' "$FAKE_CURL_LOG"
if grep -Eqi 'authorization|cookie|token' "$FAKE_CURL_LOG"; then
  exit 1
fi

PATH="$FAKE_BIN:$PATH" FAKE_CODEX_VERSION=0.148.0-alpha.1 FAKE_LATEST_CODEX_VERSION=0.148.0 \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --check-latest-codex >"$update_markdown_report"
expected_update_markdown="update_available: $(printf '\140')yes$(printf '\140')"
grep -Fq "$expected_update_markdown" "$update_markdown_report"
grep -Fq "$FAKE_BIN/codex" "$update_markdown_report"

PATH="$FAKE_BIN:$PATH" FAKE_CODEX_VERSION=0.148.0 FAKE_CURL_MODE=failure \
  CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --json --check-latest-codex >"$update_json_report"
if command -v jq >/dev/null 2>&1; then
  jq -e '
    .codex_update.requested == true and
    .codex_update.checked == false and
    .codex_update.current_version == null and
    .codex_update.latest_version == null and
    .codex_update.update_available == null and
    .summary.status == "ok"
  ' "$update_json_report" >/dev/null
fi

if CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --sessions-total-advisory-bytes 1 >/dev/null 2>&1; then
  exit 1
fi

if CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --compare nowhere --sessions-total-advisory-bytes 0 >/dev/null 2>&1; then
  exit 1
fi

if CODEX_HOME="$FIXTURE_HOME" CODEX_SQLITE_HOME="$FIXTURE_HOME" \
  "$ROOT_DIR/bin/codex-healthkit" check --compare nowhere --sessions-total-advisory-bytes 9223372036854775808 >/dev/null 2>&1; then
  exit 1
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
  jq -e '
    .state.sessions.exists == false and
    .state.sessions.jsonl_count == 0 and
    .state.sessions.session_file_count == 0 and
    .state.archived_sessions.exists == false and
    .state.archived_sessions.jsonl_count == 0 and
    .state.archived_sessions.session_file_count == 0
  ' "$json_report" >/dev/null
fi

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$ROOT_DIR/bin/codex-healthkit" "$ROOT_DIR/tests/run.sh" "$FAKE_BIN/codex"
fi

printf 'tests ok\n'
