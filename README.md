# codex-healthkit

[![CI](https://github.com/Ishikawa-Hidekazu/codex-healthkit/actions/workflows/ci.yml/badge.svg)](https://github.com/Ishikawa-Hidekazu/codex-healthkit/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Ishikawa-Hidekazu/codex-healthkit)](LICENSE)
[![Release](https://img.shields.io/github/v/release/Ishikawa-Hidekazu/codex-healthkit?include_prereleases)](https://github.com/Ishikawa-Hidekazu/codex-healthkit/releases)

Codex can keep working while local sessions and SQLite WAL quietly grow; `codex-healthkit` shows that growth without opening credentials, databases, or transcript contents.

[日本語版](README.ja.md)

`codex-healthkit` is an on-demand CLI health report for daily Codex users. It checks local session and SQLite WAL metadata before debugging, opening an issue, or asking for help.

By default, it does **not** execute `codex` or read credentials, token files, cookies, SQLite contents, or session transcript contents. It is not a daemon, dashboard, live monitor, or session recorder, and it does not require a background service or web UI. Not affiliated with OpenAI.

## 30-Second Quick Start

With `uv`, run the published package without installing it permanently:

```bash
uvx --from codex-healthkit==0.4.1 codex-healthkit check
```

Package retrieval uses PyPI. After startup, the default check needs only Bash
and standard Unix tools and does not execute `codex` or make a network request.

Without Python packaging tools, run the same pinned release from source:

```bash
git clone --branch v0.4.1 --depth 1 https://github.com/Ishikawa-Hidekazu/codex-healthkit.git && \
  ./codex-healthkit/bin/codex-healthkit check
```

This pins the latest published release instead of running the development branch.
The command prints a reviewable Markdown health report to stdout. It does not
install a daemon, modify Codex state, or upload the report.

Did the first check work? Share a public-safe
[first-run report](https://github.com/Ishikawa-Hidekazu/codex-healthkit/issues/new?template=04-first-run-report.yml)
with only your OS, `codex-healthkit --version`, run method, and result. Do not
attach the health report or include private paths or contents.

## 24-Second Terminal Demo

![A 24-second fixture-only terminal demo showing a default health report, an explicit before-and-after comparison, and the data codex-healthkit does not read.](assets/terminal-demo.gif)

The demo uses synthetic fixture values. It does not contain a real Codex home,
account, path, report, database, or transcript.

## What You Get

<picture>
  <source media="(max-width: 600px)" srcset="assets/source/health-report-mobile.svg">
  <img src="assets/source/health-report-overview.svg" alt="Fixture-only codex-healthkit output showing a default metadata-only health report and an explicit before-and-after comparison without credentials, SQLite contents, transcript contents, or uploads.">
</picture>

[View the public-safe text sample](examples/report.redacted.md) ·
[View the reproducible visual sources](assets/source/README.md)

## Choose The Narrowest Mode

| Mode | Use it for | Boundary |
| --- | --- | --- |
| Health report | `./bin/codex-healthkit check` | Local metadata only; does not execute `codex` |
| Before / after | `./bin/codex-healthkit check --compare before.json` | Compares one explicit health report; no automatic history |
| Optional doctor | `./bin/codex-healthkit check --with-codex-doctor` | Explicitly runs official `codex doctor --json`; may perform provider reachability checks |
| JSON output | Add `--json` to a health report or comparison | Same data in a machine-readable format |

Start with the default check. It is the narrowest mode and does not execute `codex`.

## Why This Exists

Heavy Codex users often need to answer simple operational questions:

- Is my local Codex state unusually large?
- Are active or archived session directories growing?
- Is the SQLite WAL file large enough to deserve attention?
- What can I safely share when asking someone else to help debug my setup?

`codex-healthkit` focuses on that narrow problem. It is not a usage dashboard, account switcher, cleanup tool, or transcript parser.

## Status

Latest release: `v0.4.1`. The existing Bash executable is distributed through
[PyPI](https://pypi.org/project/codex-healthkit/) without a Python wrapper or
runtime dependency.

The release remains intentionally narrow and read-only. For a stable daily
command, install an explicit tag rather than linking to a development checkout.

Tested on macOS and Linux. Windows is not supported by this Bash implementation.

## Who It Is For

`codex-healthkit` is for people who:

- use Codex frequently
- want a quick local operational check
- need a report they can review before sharing
- care about avoiding credential, transcript, or account-data exposure

It is especially useful before opening an issue, comparing local state over time, or asking another developer to help debug a local setup.

## Three Real-World Uses

1. **Before and after a Codex CLI update:** save one JSON report, update normally, then compare WAL and session metadata without automatic history.
2. **Daily operational review:** notice whether active sessions, archived sessions, quarantine, or SQLite files are growing before deciding whether deeper investigation is needed.
3. **Preparing a support request:** generate a small report, review it yourself, and share only the redacted metadata that is relevant to the issue.

## From Report To Decision

The report is evidence for the next check, not an instruction to delete local
state.

| What you see | What it means | Safe next step |
| --- | --- | --- |
| `session_file_count` is higher than `jsonl_count` | Recognized compressed `.jsonl.zst` session files are present in addition to uncompressed `.jsonl` files | Use the directory byte size and an explicit before/after comparison; do not infer lost or duplicate sessions from the count alone |
| Session bytes or file counts increased | Local session storage changed since the previous report | Compare against one report you deliberately saved and decide whether the growth matches normal work |
| `logs_2.sqlite-wal` grew or the summary says `watch` | A size-only threshold deserves another look | Save the report, finish or restart Codex normally if appropriate, and check again; never delete a live SQLite sidecar based only on this report |
| You need help from another person | The metadata can describe scale without exposing contents | Review the report yourself and share only the fields relevant to the issue |

`codex-healthkit` does not determine which session to archive or delete. It does
not checkpoint SQLite, clean directories, or diagnose content-level causes.

## Common Commands

JSON health report:

```bash
./bin/codex-healthkit check --json
```

Save a report:

```bash
./bin/codex-healthkit check > codex-health-report.md
./bin/codex-healthkit check --json > codex-health-report.json
```

Compare with an explicit previous report:

```bash
./bin/codex-healthkit check --json > before.json
# update Codex CLI, wait a day, or run normal work
./bin/codex-healthkit check --json --compare before.json
```

Omit `--json` on the second command when you want a Markdown comparison table.

## Install From PyPI

Install the exact release with `uv`:

```bash
uv tool install codex-healthkit==0.4.1
codex-healthkit --version
codex-healthkit check
```

Or use `pipx`:

```bash
pipx install codex-healthkit==0.4.1
```

Uninstall only the packaged command with the same tool that installed it:

```bash
uv tool uninstall codex-healthkit
# or: pipx uninstall codex-healthkit
```

The package installer downloads from PyPI. The installed command is the same
Bash executable from this repository; default checks remain local and
metadata-only.

## Tag-Pinned Source Install

For a stable daily command, keep each released tag in a versioned directory and
point a `current` symlink at the selected release. This keeps normal use separate
from development branches and makes rollback a symlink change.

```bash
VERSION=v0.4.1
INSTALL_ROOT="$HOME/.local/opt/codex-healthkit"

mkdir -p "$INSTALL_ROOT"
git clone --branch "$VERSION" --depth 1 \
  https://github.com/Ishikawa-Hidekazu/codex-healthkit.git \
  "$INSTALL_ROOT/$VERSION"

ln -sfn "$INSTALL_ROOT/$VERSION" "$INSTALL_ROOT/current"
mkdir -p ~/.local/bin
ln -sfn "$INSTALL_ROOT/current/bin/codex-healthkit" \
  ~/.local/bin/codex-healthkit
```

Verify the selected version and run the default metadata-only check before
relying on the new target:

```bash
codex-healthkit --version
codex-healthkit check --json | jq -e '.safety | all(.[]; . == false)'
git -C "$INSTALL_ROOT/$VERSION" rev-parse HEAD
```

The default check does not execute `codex`, read credentials, open SQLite or
transcript contents, clean up sessions, or upload telemetry. The `jq` expression
only verifies the safety fields already emitted by the health report.

To roll back, point `current` at a previously installed tag. The command symlink
does not need to change:

```bash
PREVIOUS_VERSION=v0.3.0
ln -sfn "$INSTALL_ROOT/$PREVIOUS_VERSION" "$INSTALL_ROOT/current"
codex-healthkit --version
codex-healthkit check --json | jq -e '.safety | all(.[]; . == false)'
```

Rollback does not delete reports, sessions, or release directories. Remove a
versioned directory separately only after confirming that `current` no longer
points to it.

Uninstall the local command without deleting reports you chose to save:

```bash
rm ~/.local/bin/codex-healthkit
```

Delete `~/.local/opt/codex-healthkit` separately when you no longer need any
installed release.

## What It Checks

By default, `codex-healthkit check` reports:

- whether the `codex` command is available, without executing it
- active session directory size, uncompressed `.jsonl` count, and recognized `.jsonl` / `.jsonl.zst` session file count
- archived session directory size, uncompressed `.jsonl` count, and recognized `.jsonl` / `.jsonl.zst` session file count
- quarantine directory size
- `logs_2.sqlite`, `logs_2.sqlite-shm`, and `logs_2.sqlite-wal` file sizes
- a small `ok` / `watch` summary based on size-only checks

It does not open SQLite databases or session transcripts.
It also does not execute the external `codex` command by default.

## Options

```text
codex-healthkit check [--markdown|--json] [--compare <previous-report.json>] [--sessions-total-advisory-bytes <bytes>] [--sessions-daily-growth-advisory-bytes <bytes>] [--with-codex-version] [--check-latest-codex] [--with-codex-doctor]
codex-healthkit --version
codex-healthkit --help
```

### `--compare`

Reads an explicit previous `codex-healthkit check --json` report and compares metadata-only values with the current check.

Use it with the default Markdown output for a readable delta table, or with `--json` for machine-readable deltas.

It compares:

- `logs_2.sqlite-wal` size
- `logs_2.sqlite` size
- active session directory size and `.jsonl` count
- archived session directory size and `.jsonl` count
- quarantine directory size

This mode requires `jq`. It does not store history, upload telemetry, read SQLite contents, or read session transcript contents.

The comparison also reports the validated interval between the previous and current `generated_at` timestamps and the active sessions byte delta normalized to one day. Canonical UTC timestamps such as `2026-08-01T00:00:00Z` are required; invalid, equal, or non-increasing timestamps leave the daily rate unavailable instead of producing a misleading value.

Optional sessions advisories are enabled only when you provide an integer byte threshold:

```bash
codex-healthkit check --json --compare before.json \
  --sessions-total-advisory-bytes 32212254720 \
  --sessions-daily-growth-advisory-bytes 4294967296
```

- `--sessions-total-advisory-bytes` may add the reason `large_total`.
- `--sessions-daily-growth-advisory-bytes` may add the reason `rapid_growth`.
- Thresholds require `--compare`; human-size strings such as `30G` are not accepted.
- Advisory results do not change summary status or exit code.
- No threshold is enabled by default, and no cleanup or deletion is performed.
- The machine-readable comparison contract is documented in [`schemas/comparison-v0.2.schema.json`](schemas/comparison-v0.2.schema.json).

### `--with-codex-version`

Runs:

```bash
codex --version
```

Use this only when you want the report to include the installed Codex CLI version.

### `--check-latest-codex`

Checks the installed Codex CLI version against the official stable npm `latest` dist-tag:

```bash
codex-healthkit check --json --check-latest-codex
```

This option implies `--with-codex-version`. It sends one HTTPS GET request to the public `@openai/codex` metadata endpoint and reports the resolved `executable_path`, `current_version`, `latest_version`, and `update_available`. The executable path makes PATH precedence differences visible without reading any file contents.

- disabled by default; the default check remains local-only
- requires `curl` and `jq`
- disables `.curlrc` loading and sends no authorization, cookie, or token header
- uses a five-second timeout and no retry
- never installs or updates Codex
- a failed check does not change summary status or exit code
- no version-check fields are added to default JSON output

### `--with-codex-doctor`

The default check does not execute `codex`. Use this option only when you also
want a summary from the official Codex CLI doctor command.

When explicitly requested, it runs:

```bash
codex doctor --json
```

Important:

- this mode requires `jq`
- Codex CLI may perform provider reachability checks through your existing Codex configuration
- this mode is not fully offline
- `codex-healthkit` reports only redacted summary fields: `status`, `ok`, `warn`, `fail`, and a note
- raw `codex doctor` output is not included in the report
- session transcript contents and SQLite contents are not read
- this option does not add cleanup, delete, or usage-dashboard behavior

## Example Output

See [examples/report.redacted.md](examples/report.redacted.md).

Short example:

```text
# codex-healthkit report

- summary: ok
- codex command found: yes
- codex version: not requested
- sessions: 40 JSONL / 42 recognized session files, 18M
- archived sessions: 3 JSONL / 7 recognized session files, 2.1M
- SQLite WAL: 0B
- auth files read: no
- session transcript contents read: no
```

## How To Read The Result

The report summary is intentionally simple:

- `ok`: no large local SQLite/WAL spike was detected by the size-only check
- `watch`: one of the local metadata values is large enough to review
- `fail`: optional official doctor mode was requested and official `codex doctor` reported failures

`watch` does not mean credentials were exposed. It also does not mean SQLite contents were read.

For more examples, see [docs/usage.md](docs/usage.md) and [docs/faq.md](docs/faq.md).

## Safety Boundary

`codex-healthkit` never reads:

- `~/.codex/auth.json`
- token files
- cookies
- localStorage
- OS credential stores
- SQLite contents
- session transcript contents
- account IDs or email addresses

`codex-healthkit` preserves the existing `.jsonl` count and separately counts recognized `.jsonl` and `.jsonl.zst` session files. It uses suffix metadata only; raw file names and transcript contents are not reported.

Reports are intended to be safe to paste into an issue after review, but users should still check them before sharing.

See [docs/safety-boundary.md](docs/safety-boundary.md).

## Documentation

- [Usage guide](docs/usage.md)
- [FAQ](docs/faq.md)
- [Safety boundary](docs/safety-boundary.md)
- [Release checklist](docs/release-checklist.md)
- [Japanese README](README.ja.md)

## Non-Goals

`codex-healthkit` does not:

- switch Codex accounts
- parse auth files
- estimate usage or quota from transcripts
- delete, archive, or clean up sessions
- read browser profiles
- upload reports
- run background telemetry

## Known Limitations

- It does not explain the cause of growth or repair Codex state.
- It does not delete, archive, compact, or clean up files.
- It does not estimate account usage, quota, or rate limits.
- It does not keep automatic history; comparisons require an explicit previous JSON report.
- Default checks are size/count observations, not SQLite integrity checks.
- Windows is not supported by this Bash implementation.
- Optional official doctor behavior can change with the installed Codex CLI.

## Requirements

Default mode:

- macOS or Linux; Windows is not supported by this Bash implementation
- Bash
- standard Unix tools: `find`, `du`, `stat`, `awk`, `wc`, `tr`

Comparison mode:

- `jq`

Optional doctor mode:

- Codex CLI
- `jq`

## Development

Run checks:

```bash
bash -n bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
tests/run.sh
```

## Getting Help

If something looks wrong:

1. Run the default check first.
2. Review and redact the report.
3. Open an issue using the closest issue template.

Quick troubleshooting:

```bash
./bin/codex-healthkit --help
bash --version
command -v find du stat awk wc tr
```

If `--compare` or `--with-codex-doctor` is unavailable, also check
`command -v jq`. Doctor mode additionally requires the official `codex` CLI.

Please do not paste credentials, tokens, cookies, private paths, raw session transcripts, or raw `codex doctor` output into public issues.

See [SUPPORT.md](SUPPORT.md).

## Opening Issues Safely

When opening an issue:

- use the closest issue template
- include the command you ran
- include your OS
- include reviewed and redacted output only
- explain what you expected and what happened instead

Do not include raw reports that you have not reviewed.

## Contributing

Small, focused contributions are welcome, especially:

- documentation improvements
- safer examples
- fixture-based tests
- Linux compatibility checks
- shell portability fixes

Please read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before opening a pull request.

## Security

Please do not include credentials, tokens, cookies, private paths, raw session transcripts, or raw `codex doctor` output in public issues.

See [SECURITY.md](SECURITY.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Roadmap

Near-term:

- continue daily use of the source-only release
- more fixture-based tests
- clearer report examples
- decide the next release only after practical improvements accumulate

Out of scope until a new safety review:

- account switching
- transcript parsing
- usage estimation
- automatic cleanup
- background monitoring
- npm package distribution

## License

MIT. See [LICENSE](LICENSE).
