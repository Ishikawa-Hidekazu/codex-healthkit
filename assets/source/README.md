# Visual Sources

The SVG files in this directory are the editable sources for the public README
and social-preview visuals.

All values are synthetic fixtures. They do not come from a real Codex home,
report, account, path, session, SQLite database, or transcript.

Render the PNG files from the repository root:

```bash
scripts/render-visuals.sh
```

Rendering requires [resvg](https://github.com/linebender/resvg) 0.47 or newer.
ImageMagick 7 is used only for output validation. Rendering does not read local
Codex state.

Generated files:

- `assets/health-report-overview.png` — desktop README visual, 1200 x 960
- `assets/health-report-mobile.png` — mobile README visual, 750 x 1200
- `assets/social-preview.png` — GitHub Social Preview candidate, 1280 x 640

The social-preview badge describes the two distribution paths, PyPI and
tag-pinned source, without embedding a version that can become stale. This
repository asset is a candidate, not confirmation of the GitHub repository's
configured Social Preview image.

Terminal demo sources:

- `assets/source/terminal-demo.svg`
- `assets/source/terminal-demo-compare.svg`
- `assets/source/terminal-demo-boundary.svg`

Render the three-frame, 24-second GIF with:

```bash
scripts/render-demo.sh
```

Each frame is 1200 x 675 and remains visible for eight seconds. All text and
values are synthetic.

The README links directly to these SVG sources for crisp text and uses a
responsive `picture` element to choose the mobile visual at 600 pixels or
narrower. The generated PNGs are review and social-preview artifacts. The
render script rejects unexpected dimensions and files larger than 500 KB.
