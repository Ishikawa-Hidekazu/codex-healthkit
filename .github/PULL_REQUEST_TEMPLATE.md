## Summary

Describe what changed and why.

## Testing

Please include the commands you ran:

```bash
bash -n bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
shellcheck bin/codex-healthkit scripts/render-visuals.sh tests/run.sh tests/fixtures/fake-bin/codex
tests/run.sh
```

## Safety Boundary

Does this change affect what the tool reads, reports, uploads, deletes, or executes?

- [ ] No
- [ ] Yes, and I explained the impact below

Notes:

## Checklist

- [ ] I did not include credentials, tokens, cookies, private paths, raw transcripts, or raw doctor output.
- [ ] Documentation was updated if behavior changed.
- [ ] Tests or fixtures were updated if behavior changed.
