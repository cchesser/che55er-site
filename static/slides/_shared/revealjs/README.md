# Shared Reveal.js Artifacts

This directory contains shared Reveal.js runtime files used by slide decks in `static/slides`.

## What belongs here

- Reveal.js core distribution files in `dist/`
- Generic plugins in `plugin/` that can be reused across talks (for example `notes`, `markdown`, `highlight`, `math`, `search`, `zoom`)

## What does not belong here

- Talk-specific assets like `img/`, `video/`, `examples/`
- Talk-specific plugins or custom scripts (keep in each talk directory)
- Talk-specific style overrides unless they are intentionally shared by all decks

## Standard Includes For New Decks

From a talk folder like `static/slides/<talk-name>/index.html`, reference:

- `../_shared/revealjs/dist/reset.css`
- `../_shared/revealjs/dist/reveal.css`
- a theme, for example `../_shared/revealjs/dist/theme/black.css`
- optional plugin CSS like `../_shared/revealjs/plugin/highlight/monokai.css`
- `../_shared/revealjs/dist/reveal.js`
- required plugin scripts such as:
  - `../_shared/revealjs/plugin/notes/notes.js`
  - `../_shared/revealjs/plugin/markdown/markdown.js`
  - `../_shared/revealjs/plugin/highlight/highlight.js`

Load only the plugins each deck actually uses.

## Upgrade Flow

1. Replace shared Reveal.js files in this directory with the new version.
2. Keep folder structure stable (`dist/`, `plugin/...`) to avoid changing every deck.
3. Smoke-test at least one existing deck and one new deck:
   - deck renders
   - keyboard navigation works
   - notes and plugin behavior still work
