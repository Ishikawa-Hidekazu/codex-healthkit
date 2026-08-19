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
bash -n bin/codex-healthkit tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit tests/run.sh tests/fixtures/fake-bin/codex
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

### `v0.4.1` candidate - approved for release

Scope:

- Include the post-`v0.4.0` compressed session file count without changing the existing `jsonl_count` field.
- Add report-to-decision guidance without cleanup, deletion, checkpoint, daemon, or telemetry behavior.
- Publish the reviewed Bash executable through PyPI without a Python wrapper or runtime dependency.
- Preserve default JSON compatibility apart from the additive `session_file_count` field already merged to `main`.

Gate:

- [ ] Confirm the final release commit contains the same tree tested from the candidate branch.
- [ ] Confirm `README.md`, `README.ja.md`, `CHANGELOG.md`, CLI version, tag, and release notes agree on `v0.4.1`.
- [ ] Run Bash syntax, ShellCheck, tests, actionlint, gitleaks, Linux CI, and macOS CI.
- [ ] Verify an anonymous tagged clone and isolated tag-pinned install.
- [ ] Verify isolated sdist/wheel builds, package metadata, wheel contents, `uv tool install`, `uvx`, and `pipx`.
- [ ] Confirm the Trusted Publisher identity is `Ishikawa-Hidekazu/codex-healthkit`, workflow `publish-pypi.yml`, environment `pypi`.
- [ ] Verify anonymous PyPI installs and the metadata-only safety fields after publication.
- [ ] Confirm default mode still reads no credentials, tokens, cookies, SQLite contents, or transcript contents.
- [x] Obtain the explicit packaging PR, tag, GitHub Release, and PyPI publication gate.

### `v0.4.0` - 2026-08-11

- [x] Updated `CHANGELOG.md` and the CLI version.
- [x] Confirmed `README.md` and `README.ja.md` match current behavior.
- [x] Confirmed `SECURITY.md` reporting path is current.
- [x] Ran local Bash syntax, ShellCheck, tests, actionlint, and gitleaks.
- [x] Verified an anonymous candidate clone, `v0.3.0` default JSON compatibility after version normalization, and an isolated live stable-version check.
- [x] Ran Linux and macOS checks in GitHub Actions.
- [x] Confirmed the release-candidate commits are in English.
- [x] Reviewed normal-release notes before creating the tag and GitHub Release.
- [x] Verified the published annotated tag, anonymous clone, stable local install, and [public Release URLs](https://github.com/Ishikawa-Hidekazu/codex-healthkit/releases/tag/v0.4.0).

### `v0.3.0` - 2026-08-02

- [x] Updated `CHANGELOG.md` and the CLI version.
- [x] Confirmed `README.md` and `README.ja.md` match current behavior.
- [x] Confirmed `SECURITY.md` reporting path is current.
- [x] Ran local Bash syntax, ShellCheck, tests, actionlint, and gitleaks.
- [x] Ran Linux and macOS checks in GitHub Actions.
- [x] Confirmed the release-candidate commit is in English.
- [x] Reviewed normal-release notes before creating the tag and GitHub Release.
- [x] Verified the published tag, anonymous clone, and [public Release URLs](https://github.com/Ishikawa-Hidekazu/codex-healthkit/releases/tag/v0.3.0).

### `v0.2.0` - 2026-07-27

- [x] Updated `CHANGELOG.md`.
- [x] Confirmed `README.md` and `README.ja.md` match current behavior.
- [x] Confirmed `SECURITY.md` reporting path is current.
- [x] Ran macOS checks.
- [x] Ran Linux checks in GitHub Actions.
- [x] Confirmed the release-candidate commit is in English.
- [ ] Reviewed the normal-release notes before creating the tag and GitHub Release.
- [x] Verified a fresh branch clone, check, local symlink install, and uninstall.

### `v0.1.0-alpha.1` - 2026-07-06

- [x] Updated `CHANGELOG.md`.
- [x] Confirmed `README.md` and `README.ja.md` match current behavior.
- [x] Confirmed `SECURITY.md` reporting path is current.
- [x] Ran macOS checks.
- [x] Ran Linux checks in GitHub Actions and an Ubuntu 24.04 Docker container.
- [x] Confirmed public commit messages are in English.
- [x] Reviewed release notes before creating the GitHub release.
