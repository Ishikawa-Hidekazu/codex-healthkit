# Security Policy

## Scope

Security-sensitive areas for this project include:

- accidental reading of Codex auth files, token files, cookies, SQLite contents, or session transcript contents
- accidental inclusion of account identifiers, email addresses, workspace identifiers, raw paths, or transcript data in reports
- package or release artifacts that differ from the public source tree
- install scripts or release workflows that execute unexpected code

## Safety Commitments

`codex-healthkit` is designed to be local, narrow, and read-only.

By default it performs local file metadata checks only. It does not read `auth.json`, token files, cookies, SQLite contents, or session transcript contents.

When official Codex doctor integration is enabled, Codex CLI may perform its own provider reachability checks. `codex-healthkit` should only summarize redacted status fields and must not include raw doctor output by default.

## Reporting A Vulnerability

Do not include secrets, tokens, private logs, raw `auth.json`, SQLite contents, or session transcripts in public issues.

After the public GitHub repository is created, prefer GitHub private vulnerability reporting / security advisories:

https://github.com/Ishikawa-Hidekazu/codex-healthkit/security/advisories/new

If GitHub private reporting is not available, contact the maintainer through:

https://ishikawa.co/contact/

Send only a short note that you have a security report. Do not include secrets or exploit details in the first message.

## What To Include

For private reports, include:

- affected command or mode
- expected safety boundary
- observed behavior
- minimal reproduction steps
- whether any sensitive data may have been exposed

Please redact local paths and identifiers unless they are essential to understand the vulnerability.

## Public Issues

Use public issues for non-sensitive safety-boundary questions only.

Do not post exploit details, private output, credentials, tokens, cookies, raw transcripts, or raw `codex doctor` output in public issues.

## Supported Versions

This project is pre-1.0. Only the current `main` branch is supported during initial development.
