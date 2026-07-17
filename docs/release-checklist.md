# Release Checklist

Use this checklist before public releases.

## Initial Public Push

Completed for the initial public alpha:

- [x] Confirm repository name: `Ishikawa-Hidekazu/codex-healthkit`.
- [x] Confirm repository visibility is intended to be public.
- [x] Re-run local checks.
- [x] Confirm README clone URL works after repository creation.
- [x] Confirm no credentials, tokens, private paths, or raw local reports are committed.
- [x] Confirm public git history contains only files and notes intended for release.
- [x] Enable GitHub private vulnerability reporting / security advisories if available.
- [x] Confirm GitHub community profile recognizes core public repository files.

## Local Checks

```bash
bash -n bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
tests/run.sh
git diff --check
```

Current-tree secret-pattern scan:

```bash
rg -n --hidden -g '!.git/**' -e 'AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|ghp_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}|sk-[A-Za-z0-9_-]{20,}|Bearer [A-Za-z0-9._~+/=-]{20,}|BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|xox[baprs]-[0-9A-Za-z-]+' .
```

History wording and secret-pattern scan:

```bash
git grep -n -E 'AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|ghp_[A-Za-z0-9_]{30,}|github_pat_[A-Za-z0-9_]{30,}|sk-[A-Za-z0-9_-]{20,}|Bearer [A-Za-z0-9._~+/=-]{20,}|BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|xox[baprs]-[0-9A-Za-z-]+' $(git rev-list --all)
git grep -n -E 'internal handoff|business strategy|client workflow|private workflow|事業導線|内部メモ|クライアント|案件名' $(git rev-list --all)
```

If `gitleaks` is available:

```bash
gitleaks detect --redact --source .
```

## Before Tagging

- [ ] Update `CHANGELOG.md`.
- [ ] Confirm `README.md` and `README.ja.md` match current behavior.
- [ ] Confirm `SECURITY.md` reporting path is current.
- [ ] Run macOS checks.
- [ ] Run Linux checks before claiming Linux support.
- [ ] Confirm public commit messages are in English.
- [ ] Create a GitHub release only after the tag and release notes are reviewed.

## Not Yet In Scope

- npm package publishing
- binary release artifacts
- Homebrew formula
- automated cleanup features
- transcript-based usage analysis

Each item above needs a separate safety and release review.

## Release Gate Log

### `v0.1.0-alpha.1` - 2026-07-06

- [x] Updated `CHANGELOG.md`.
- [x] Confirmed `README.md` and `README.ja.md` match current behavior.
- [x] Confirmed `SECURITY.md` reporting path is current.
- [x] Ran macOS checks.
- [x] Ran Linux checks in GitHub Actions and an Ubuntu 24.04 Docker container.
- [x] Confirmed public commit messages are in English.
- [x] Reviewed release notes before creating the GitHub release.

### `v0.1.0-alpha.2` release candidate - 2026-07-17

- [x] Confirm `v0.1.0-alpha.1..main` contains the intended six commits before this release PR.
- [x] Confirm package version `0.1.0-alpha.2` matches tag candidate `v0.1.0-alpha.2`.
- [x] Review explicit previous-report comparison and optional doctor boundaries.
- [x] Confirm English and Japanese README files match current behavior.
- [x] Confirm fixture-only README visuals and Social Preview contain no real local state.
- [x] Review the Social Preview at 1280 x 640 and a reduced card size.
- [x] Run local macOS checks, gitleaks, and same-environment render reproducibility QA.
- [ ] Confirm GitHub Linux/macOS checks and fresh-clone QA for the release candidate commit.
- [x] Review `docs/releases/v0.1.0-alpha.2.md` before merge.
- [ ] After central QA, merge through protected `main`, then create the tag and prerelease separately.
- [ ] After publishing, update README latest-tag wording from alpha.1 to alpha.2.

No PyPI package, Homebrew formula, binary, or manually attached artifact is part of this candidate.
