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

### Optional sessions advisory

Every loaded comparison includes a validated interval and an active sessions byte delta normalized to 24 hours. Invalid, equal, or non-increasing `generated_at` timestamps leave the daily rate unavailable.

To evaluate explicit thresholds without changing the normal summary or exit code:

```bash
./bin/codex-healthkit check --compare before.json \
  --sessions-total-advisory-bytes 32212254720 \
  --sessions-daily-growth-advisory-bytes 4294967296
```

Threshold values are integer bytes. They are disabled unless explicitly provided and require `--compare`. The advisory reasons are `large_total` and `rapid_growth`. A result is a prompt to review metadata, not proof that sessions are unhealthy. The command never deletes or cleans up sessions.

The JSON shape for the comparison object is documented in [`../schemas/comparison-v0.2.schema.json`](../schemas/comparison-v0.2.schema.json).

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

## Optional Stable Codex Version Check

Run:

```bash
./bin/codex-healthkit check --json --check-latest-codex
```

This implies `--with-codex-version` and compares the installed version with the official npm `latest` dist-tag for `@openai/codex`. The result includes the resolved `executable_path`, so a different PATH entry is not mistaken for a failed or incomplete update.

The request is deliberately bounded:

- opt-in only; default checks remain local-only
- one public HTTPS metadata request with a five-second timeout and no retry
- `.curlrc` is disabled and no authorization, cookie, or token header is sent
- response data is accepted only when `version` matches the expected semver shape
- no install, update, cleanup, storage, or telemetry is performed
- unavailable network, tools, or response data leaves `update_available` as `null`
- failures do not change summary status or exit code

Use the result as an update decision aid, not as an automatic update trigger.

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

## Interpreting Summary Status

`ok` means no large local SQLite/WAL spike was detected by the size-only check.

`watch` means one of the local metadata values is large enough to deserve another look. It does not mean `codex-healthkit` read SQLite contents or found a credential problem.

`fail` can appear when optional official doctor mode is requested and official `codex doctor` reports failures.

## Sharing Reports

Before sharing:

1. Prefer the default report first.
2. Read the output yourself.
3. Remove private paths or identifiers if they appear.
4. Do not paste raw `codex doctor` output.
5. Do not paste raw session transcripts.

When in doubt, share less.
