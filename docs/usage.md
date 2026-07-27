# Usage Guide

This guide explains how to run `codex-healthkit` and how to read the report.

## Default Check

Run:

```bash
./bin/codex-healthkit check
```

Default mode is the safest mode. It checks local file metadata only and does not execute the external `codex` command.

Use this first when you want a report to review or paste into an issue.

## JSON Output

Run:

```bash
./bin/codex-healthkit check --json
```

Use JSON when you want to compare reports over time or feed the output into another local script.

Validate JSON:

```bash
./bin/codex-healthkit check --json | jq empty
```

## Previous Report Comparison

Run:

```bash
./bin/codex-healthkit check --json > before.json
# update Codex CLI, wait a day, or run normal work
./bin/codex-healthkit check --json --compare before.json
```

`--compare` reads one explicit previous `codex-healthkit check --json` report and compares metadata-only values with the current check.

Use the default Markdown output for a readable delta table:

```bash
./bin/codex-healthkit check --compare before.json
```

It compares:

- `logs_2.sqlite-wal` size
- `logs_2.sqlite` size
- active session directory size and `.jsonl` count
- archived session directory size and `.jsonl` count
- quarantine directory size

Important:

- requires `jq`
- does not store history automatically
- does not upload telemetry
- does not read SQLite contents
- does not read session transcript contents
- comparison output is informational and does not make archived session growth a warning by itself

If both reports include macOS runtime metadata, comparison also shows Renderer start/exit candidates and worker count deltas. PID plus an estimated, minute-bucketed start time is used to reduce PID-reuse ambiguity. Four combined Renderer start/exit events make `churn_candidate` true. This is a prompt to review, not proof of instability.

## Optional Codex Version

Run:

```bash
./bin/codex-healthkit check --with-codex-version
```

This executes:

```bash
codex --version
```

Use it when an issue or debugging conversation needs the installed Codex CLI version.

## Optional Official Doctor Summary

The default check does not execute the external `codex` command. Add the
doctor option only when the official Codex CLI diagnostics are needed.

Run:

```bash
./bin/codex-healthkit check --with-codex-doctor
```

This executes:

```bash
codex doctor --json
```

Important:

- requires `jq`
- runs official `codex doctor --json` only when this option is explicitly provided
- Codex CLI may perform provider reachability checks through the existing Codex configuration
- not fully offline
- only redacted `status`, `ok`, `warn`, `fail`, and note fields are included
- raw doctor output is not included in the report
- session transcript contents and SQLite contents are not read
- no cleanup, delete, or usage-dashboard behavior is added

## Optional macOS Runtime Metadata

Run:

```bash
./bin/codex-healthkit check --with-runtime
```

This mode uses macOS `memory_pressure`, `sysctl vm.swapusage`, and `ps` with only PID, PPID, RSS, elapsed time, and executable name fields. The executable name is immediately reduced to one of four public categories: Codex Renderer, Computer Use client, Computer Use service, or Playwright worker.

Thresholds:

- swap: `observe` at 4096 MiB, `watch` at 8192 MiB
- memory free: `observe` at 20% or lower, `watch` at 10% or lower
- long-running candidate: 21600 seconds (six hours)
- Renderer churn candidate: four combined start/exit events between two explicit reports
- worker growth candidate: count increase of 10 or more between two explicit reports

An orphan candidate means PPID 0/1 or a parent PID absent from the same process snapshot. A residual candidate requires both an orphan signal and six-hour uptime. A missing parent can also be a timing race. High count, high RSS, or long uptime can be normal during parallel work. The report distinguishes these signals and does not stop any process.

On Linux and other non-macOS systems, runtime diagnostics report `unsupported`; the existing file metadata checks continue normally.

## Interpreting Summary Status

`ok` means no large local SQLite/WAL spike was detected by the size-only check.

`watch` means one of the local file values, or an explicitly requested runtime pressure value, is large enough to deserve another look. It does not mean `codex-healthkit` read SQLite contents, found a credential problem, or proved a process leak.

`fail` can appear when optional official doctor mode is requested and official `codex doctor` reports failures.

## Sharing Reports

Before sharing:

1. Prefer the default report first.
2. Read the output yourself.
3. Remove private paths or identifiers if they appear.
4. Do not paste raw `codex doctor` output.
5. Do not paste raw session transcripts.

When in doubt, share less.
