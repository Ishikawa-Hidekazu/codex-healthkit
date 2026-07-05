# Release Checklist

Use this checklist before public releases.

## Before First Public Push

- [ ] Confirm repository name: `Ishikawa-Hidekazu/codex-healthkit`.
- [ ] Confirm repository visibility is intended to be public.
- [ ] Re-run local checks.
- [ ] Confirm README clone URL works after repository creation.
- [ ] Confirm no credentials, tokens, private paths, or raw local reports are committed.
- [ ] Confirm public git history contains only files and notes intended for release.
- [ ] Enable GitHub private vulnerability reporting / security advisories if available.
- [ ] Confirm GitHub community profile recognizes README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, and issue templates.

## Local Checks

```bash
bash -n bin/codex-healthkit tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit tests/run.sh tests/fixtures/fake-bin/codex
tests/run.sh
git diff --check
```

Secret-pattern scan:

```bash
rg -n --hidden -g '!.git/**' -e 'AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY|xox[baprs]-[0-9A-Za-z-]+' .
```

## Before Tagging

- [ ] Update `CHANGELOG.md`.
- [ ] Confirm `README.md` and `README.ja.md` match current behavior.
- [ ] Confirm `SECURITY.md` reporting path is current.
- [ ] Run macOS checks.
- [ ] Run Linux checks before claiming Linux support.
- [ ] Create a GitHub release only after the tag and release notes are reviewed.

## Not Yet In Scope

- npm package publishing
- binary release artifacts
- Homebrew formula
- automated cleanup features
- transcript-based usage analysis

Each item above needs a separate safety and release review.
