#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT
mkdir -p "$temporary/bin" "$temporary/home" "$temporary/state" "$temporary/work"
jq_path="$(command -v jq)"
ln -s "$jq_path" "$temporary/bin/jq"

# Stub package retrieval, not the CLI: execute the real metadata-only checker.
cat >"$temporary/bin/uvx" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
test "$1" = --from
test "$2" = codex-healthkit==0.4.1
test "$3" = codex-healthkit
shift 3
exec "$HEALTHKIT_TEST_EXECUTABLE" "$@"
SH
cat >"$temporary/bin/codex" <<'SH'
#!/usr/bin/env bash
touch "$HEALTHKIT_UNEXPECTED_EXECUTION"
exit 99
SH
cp "$temporary/bin/codex" "$temporary/bin/curl"
chmod +x "$temporary/bin/uvx" "$temporary/bin/codex" "$temporary/bin/curl"

for document in README.md README.ja.md README.pypi.md docs/usage.md; do
  if [[ "$document" == README.md ]]; then
    section="$(awk '/^## Common Commands$/{active=1;next} active && /^## /{exit} active{print}' "$ROOT_DIR/$document")"
  elif [[ "$document" == README.ja.md ]]; then
    section="$(awk '/^## よく使うコマンド$/{active=1;next} active && /^## /{exit} active{print}' "$ROOT_DIR/$document")"
  else
    section="$(<"$ROOT_DIR/$document")"
  fi
  if grep -q '^\./bin/codex-healthkit check' <<<"$section"; then
    echo "source-only command in no-install documentation: $document" >&2
    exit 1
  fi
  command_line="$(awk '/^uvx .*codex-healthkit check --json$/{print;exit}' <<<"$section")"
  comparison_line="$(awk '/^uvx .*codex-healthkit check --json --compare before.json$/{print;exit}' <<<"$section")"
  test -n "$command_line"
  test -n "$comparison_line"
  (
    cd "$temporary/work"
    env -i HOME="$temporary/home" PATH="$temporary/bin:/usr/bin:/bin" \
      CODEX_HOME="$temporary/state" CODEX_SQLITE_HOME="$temporary/state" \
      HEALTHKIT_TEST_EXECUTABLE="$ROOT_DIR/bin/codex-healthkit" \
      HEALTHKIT_UNEXPECTED_EXECUTION="$temporary/unexpected" \
      bash -c "$command_line" >report.json
    "$jq_path" -e '.summary.status == "ok" and
      .state.sessions.exists == false and
      (.safety | all(.[]; . == false))' report.json >/dev/null
    cp report.json before.json
    env -i HOME="$temporary/home" PATH="$temporary/bin:/usr/bin:/bin" \
      CODEX_HOME="$temporary/state" CODEX_SQLITE_HOME="$temporary/state" \
      HEALTHKIT_TEST_EXECUTABLE="$ROOT_DIR/bin/codex-healthkit" \
      HEALTHKIT_UNEXPECTED_EXECUTION="$temporary/unexpected" \
      bash -c "$comparison_line" >comparison.json
    "$jq_path" -e '.comparison.loaded == true and
      (.safety | all(.[]; . == false))' comparison.json >/dev/null
  )
done
test ! -e "$temporary/unexpected"
echo "no-install documentation: 4 launchers passed without Codex execution or curl"
