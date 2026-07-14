# Contributing

Thank you for taking a look at `codex-healthkit`.

This project is early and intentionally small. The most helpful contributions are clear bug reports, safety-boundary review, documentation improvements, and small focused patches.

## Before You Open An Issue

Please check:

1. You are using the latest `main` branch.
2. The issue is about `codex-healthkit`, not the Codex CLI itself.
3. Your report does not include secrets, private paths, account identifiers, raw session transcripts, or raw `codex doctor` output.

If you are unsure whether something is safe to share, remove it first.

## Good First Contributions

Useful early contributions include:

- clearer README wording
- safer examples
- fixture-based tests
- Linux compatibility checks
- shell portability fixes
- typo fixes
- issue reproduction steps

Please keep pull requests small and focused.

## Development Setup

Clone the repository:

```bash
git clone https://github.com/Ishikawa-Hidekazu/codex-healthkit.git
cd codex-healthkit
```

Run checks:

```bash
bash -n bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
tests/run.sh
```

`shellcheck` is optional for users, but pull requests should pass it.

## Pull Request Guidelines

Please include:

- what changed
- why it changed
- how you tested it
- whether the change affects the safety boundary

Avoid broad rewrites unless they are discussed first.

## Safety Boundary Review

Any change that touches file discovery, report output, optional Codex CLI execution, packaging, or upload behavior needs extra review.

Do not add features that read:

- auth files
- token files
- cookies
- localStorage
- SQLite contents
- session transcript contents
- account identifiers

If a future feature needs any of those, it should be designed as a separate proposal before implementation.

## Commit Messages

Use English for commit messages in the public repository history.

Use simple product-oriented messages:

```text
Add JSON report output
Clarify doctor mode safety note
Handle missing session directories
```

Keep commit messages focused on the product change.

## Code Of Conduct

By participating in this project, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
