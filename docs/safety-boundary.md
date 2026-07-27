# Safety Boundary

`codex-healthkit` exists to make daily Codex environment checks easier without turning diagnostics into a credential or transcript risk.

## Default Mode

Default command:

```bash
codex-healthkit check
```

Default mode performs local file metadata checks only.

It does not execute the external `codex` command. Running official Codex CLI
diagnostics requires the explicit `--with-codex-doctor` option described below.

It may check:

- whether the `codex` command exists
- directory sizes
- `.jsonl` file counts
- SQLite-related file sizes

It must not read:

- `auth.json`
- token files
- cookie stores
- localStorage
- OS credential stores
- SQLite contents
- session transcript contents
- account IDs
- email addresses
- workspace IDs

`codex-healthkit` counts `.jsonl` files under session directories. Raw file names must not be included in reports.

## Optional Codex Doctor Integration

Command:

```bash
codex-healthkit check --with-codex-doctor
```

Only when explicitly requested, this runs official `codex doctor --json`.
`codex-healthkit` includes only redacted `status`, `ok`, `warn`, `fail`, and
note fields in its report. Raw doctor output is not included.

Important: Codex CLI may perform provider reachability checks through the
existing Codex configuration when this option is enabled. Do not describe this
mode as fully offline or never touching the network. This option does not read
session transcript contents or SQLite contents, and it does not add cleanup,
delete, or usage-dashboard behavior.

## Optional macOS Runtime Metadata

Command:

```bash
codex-healthkit check --with-runtime
```

This option may collect memory-free percentage, swap used, target process PID/PPID, RSS, elapsed uptime, an estimated minute-bucketed start time, parent-PID presence, normalized target categories, and aggregate counts.

It must not collect or report command arguments, environment variables, open files, raw executable paths, parent command names, credentials, tokens, cookies, or browser state.

Classification uses executable names only and discards the raw value after matching. Generic processes such as `node` are not attributed to Playwright by inspecting arguments. Runtime diagnostics are macOS-only; unsupported systems continue the existing check.

PPID 0/1, an absent parent, long uptime, high count, and Renderer PID changes are candidates for review rather than definitive orphan, leak, or churn findings. Runtime mode never stops, kills, restarts, or cleans up processes.

## Optional Previous Report Comparison

Command:

```bash
codex-healthkit check --json --compare previous-report.json
```

This reads one explicit previous `codex-healthkit check --json` report and compares only metadata values that `codex-healthkit` already emits.

It may compare:

- SQLite-related file sizes
- session directory sizes
- `.jsonl` file counts
- quarantine directory size

It must not:

- store history automatically
- upload telemetry
- read credentials, tokens, or cookies
- read SQLite contents
- read session transcript contents
- treat archived session growth as a warning by itself

## Sharing Reports

Reports are intended to be safe to paste into an issue after review, but users should still check them before sharing.

Safe report fields:

- status
- version string
- file sizes
- file counts
- redacted doctor status counts
- bounded runtime PID/PPID/RSS/uptime metadata when explicitly requested

Unsafe report fields:

- raw auth details
- raw doctor output
- raw paths containing usernames or private project names
- session IDs
- file names
- transcripts
- account identifiers
- process command arguments, environment variables, and open files

## Future Features That Need A New Review

These are intentionally out of scope for v0.1:

- account switching
- auth status
- usage or quota estimation from session JSONL
- session timelines
- CodexBar integration
- ctx integration
- cleanup, archive, or delete actions
- background daemon mode
- npm binary packages with platform-specific install logic
