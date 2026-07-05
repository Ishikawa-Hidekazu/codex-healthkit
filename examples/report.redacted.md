# codex-healthkit report

Generated: 2026-07-05T00:00:00Z

## Summary

- status: `ok`
- sqlite_note: ok: no large WAL spike detected by size-only check.
- default_mode: local file metadata only

## Codex CLI

- found: `yes`
- version: `not requested`
- version_requested: `no`

## Local State Metadata

| item | exists | bytes | size | count | note |
|---|---:|---:|---:|---:|---|
| active sessions | yes | 12345 | 12K | 2 | file count only; transcript contents not read |
| archived sessions | no | 0 | 0B | 0 | review before deleting |
| quarantine | no | 0 | 0B | - | metadata only |
| logs_2.sqlite | yes | 4096 | 4.0K | - | size only; SQLite contents not read |
| logs_2.sqlite-shm | no | 0 | 0B | - | size only |
| logs_2.sqlite-wal | no | 0 | 0B | - | size only |

## Official Codex Doctor

- requested: `no`
- ran: `no`
- status: `skipped`
- checks: `ok=0 warn=0 fail=0`
- note: not requested; pass --with-codex-doctor to run official Codex doctor

When `--with-codex-doctor` is enabled, Codex CLI may perform provider reachability checks using your existing Codex configuration.

## Safety

- auth files read: `no`
- token files read: `no`
- cookies read: `no`
- SQLite contents read: `no`
- session transcript contents read: `no`
- healthkit telemetry/upload: `no`

Not affiliated with OpenAI.
