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
- may perform provider reachability checks through Codex CLI
- not fully offline
- raw doctor output is not included in the report

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

