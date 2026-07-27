# FAQ

## Is this an official OpenAI project?

No. `codex-healthkit` is an independent open source project and is not affiliated with OpenAI.

## Does default mode run `codex`?

No. Default mode checks whether the `codex` command exists, but it does not execute it.

## Does it read my Codex auth file?

No. It must not read `auth.json`, token files, cookies, localStorage, OS credential stores, SQLite contents, or session transcript contents.

## Why does it count `.jsonl` files?

Counting session files helps users understand local state growth without reading transcript contents. Raw file names are not reported.

## What does `watch` mean?

`watch` means a local file check, or an explicitly requested macOS runtime pressure check, found something large enough to review.

It does not mean the tool read database contents, exposed credentials, or proved that a process is leaked or orphaned.

## Does runtime mode read process commands?

No. `--with-runtime` uses only PID, PPID, RSS, elapsed time, and executable name metadata. It does not read command arguments, environment variables, or open files. Raw executable paths and parent command names are not reported.

## Will runtime mode kill stale workers?

No. Orphan, long-running, worker-growth, and Renderer-churn values are conservative review candidates. The tool does not stop, restart, or clean up processes.

## Why is `--with-codex-doctor` optional?

Official `codex doctor` is useful, but it may perform provider reachability checks through your existing Codex configuration. That is why `codex-healthkit` does not run it by default.

## Can I paste the report into a GitHub issue?

The report is designed to be reviewable and low-risk, but you should always read it first. Remove private paths, account identifiers, or anything you do not want public.

## Does this clean up my Codex data?

No. v0.1 is read-only. It does not delete, archive, compact, or clean up files.

## Will this estimate my usage or quota?

No. Usage estimation would likely require transcript or account-state analysis, which is outside the v0.1 safety boundary.
