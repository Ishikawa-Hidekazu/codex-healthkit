# codex-healthkit

`codex-healthkit` is an on-demand, metadata-only Bash CLI health report for
people who use OpenAI Codex every day. It reports local session counts and
sizes, archived-session metadata, quarantine size, and SQLite/WAL file sizes.

By default, it does **not** execute `codex`, make a network request, or read
credentials, tokens, cookies, SQLite contents, or session transcript contents.
It is not a daemon, dashboard, cleanup tool, or session recorder. Not affiliated
with or endorsed by OpenAI.

## Try It

Run the exact release without a persistent install:

```bash
uvx --from codex-healthkit==0.4.1 codex-healthkit check
```

Install with `uv`:

```bash
uv tool install codex-healthkit==0.4.1
codex-healthkit --version
codex-healthkit check
```

Or install with `pipx`:

```bash
pipx install codex-healthkit==0.4.1
```

Package retrieval uses PyPI. The installed command is the reviewed Bash
executable from the public repository and has no runtime package dependencies.
The default check remains local after startup.

## Modes

- `codex-healthkit check`: local metadata-only health report
- `codex-healthkit check --json`: machine-readable report
- `codex-healthkit check --compare before.json`: explicit before/after metadata comparison
- `codex-healthkit check --with-codex-version`: opt-in installed Codex version
- `codex-healthkit check --with-codex-doctor`: opt-in official Codex doctor summary

Start with the default check. Optional modes have separate execution and network
boundaries documented in the repository.

## Compatibility

- macOS and Linux
- Bash and standard Unix tools
- `jq` for comparison and official doctor modes
- Windows is not supported by this Bash implementation

## Project Links

- [Source and full documentation](https://github.com/Ishikawa-Hidekazu/codex-healthkit)
- [Safety boundary](https://github.com/Ishikawa-Hidekazu/codex-healthkit/blob/main/docs/safety-boundary.md)
- [Usage guide](https://github.com/Ishikawa-Hidekazu/codex-healthkit/blob/main/docs/usage.md)
- [Changelog](https://github.com/Ishikawa-Hidekazu/codex-healthkit/blob/main/CHANGELOG.md)
- [Issue tracker](https://github.com/Ishikawa-Hidekazu/codex-healthkit/issues)
- [Security policy](https://github.com/Ishikawa-Hidekazu/codex-healthkit/security/policy)
- [Japanese README](https://github.com/Ishikawa-Hidekazu/codex-healthkit/blob/main/README.ja.md)
