# Changelog

All notable changes to this project will be documented in this file.

This project follows a simple pre-1.0 changelog style. Dates use UTC.

## Unreleased

- Add an opt-in metadata-only check for local Computer History memory size and Markdown file count without reading memory contents or interaction events.
- Add a separate metadata-only session file count for recognized `.jsonl` and `.jsonl.zst` files while preserving `jsonl_count` compatibility.
- Add an English and Japanese report-to-decision guide that explicitly avoids cleanup or live SQLite sidecar deletion advice.

## 0.4.0 - 2026-08-11

- Add an opt-in stable Codex CLI version check against the official npm `latest` dist-tag, including the resolved executable path.
- Keep the default check offline and preserve summary status, exit codes, and update behavior.
- Report version-check failures as metadata only and never install or update Codex automatically.

## 0.3.0 - 2026-08-02

- Add comparison interval and daily-normalized active sessions growth metadata.
- Add opt-in sessions total and daily growth advisories with separate `large_total` and `rapid_growth` reasons.
- Document a tag-pinned install directory, stable `current` symlink, verification, and symlink-only rollback.
- Keep default checks, summary status, exit codes, storage, and cleanup behavior unchanged.

## 0.2.0 - 2026-07-27

- Add a fixture-only 24-second terminal demo.
- Add three real-world use cases and explicit known limitations.
- Add fixture-only responsive README visuals and a reproducible Social Preview candidate.
- Clarify the 30-second quick start, mode boundaries, uninstall steps, dependencies, and troubleshooting.
- Add explicit `--compare <previous-report.json>` metadata comparison mode.
- Publish the reviewed source-only feature set as the first normal release.

## 0.1.0-alpha.1 - 2026-07-06

- Initial source-only alpha release.
- Initial public repository preparation.
- Add local metadata-only health report command.
- Add Markdown and JSON output.
- Add explicit `--with-codex-version` and `--with-codex-doctor` options.
- Add safety-boundary documentation.
- Add English and Japanese README files.
- Add tests and public repository health files.
- Add public English commit-message guidance.
- Clarify source-only alpha status before tagged releases.
- Add stronger release-gate secret scanning guidance.
