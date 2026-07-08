# Council

The public site for **Council** — a diceless, narrative-first tabletop
roleplaying game, "played with words, not dice." Live at
**[fuckinphilosophers.com](https://fuckinphilosophers.com)**.

**Hosting is Cloudflare Workers (static assets),** migrated from GitHub
Pages, deployed via Cloudflare's own dashboard Git integration — no GitHub
Actions secrets involved. Cloudflare's build command runs
`scripts/cloudflare-build.sh`, which downloads Zola's static binary
directly (its build image has no Nix) and builds the site. See
[`CLOUDFLARE_MIGRATION.md`](CLOUDFLARE_MIGRATION.md) for the full runbook
and current status. `wrangler.jsonc` holds the Cloudflare config
(`assets.directory: "public"`, the directory that build script produces).

The site has these sections:

- **`/`** — the main landing page, now with a **work timeline** of what has been
  built (see below).
- **`/rules/`** — **The Handbook**: the finished rules of the game, one markdown
  file per chapter, added as each is settled.
- **`/archive/`** — **The Archive**: the development record of the *system* —
  every draft, ruling, and book in the order it was made. Deliberately **does
  not** include the Council of Un campaign material.
- **`/un/`** — **Council of Un**, the personal campaign corner, with its own
  visual identity and (eventually) interactive table tools.

## Layout

| Path                          | What it is                                               |
| ----------------------------- | -------------------------------------------------------- |
| `site/`                       | The [Zola](https://www.getzola.org) project.             |
| `site/content/`               | Pages (`_index.md` → `/`, `un/_index.md` → `/un/`).      |
| `site/data/`                  | Data files read at build via `load_data` (`timeline.toml`, `archive.toml`). |
| `site/templates/`             | Tera templates; `base.html` is the shared skeleton.      |
| `site/static/`                | Copied verbatim to the output root (css, js, archive docs). |
| `site/static/archive/`        | The archived documents themselves (`docs/*.dc.html` + `pdf/*.pdf`). |
| `site/static/js/council-config.js` | The backend seam — API base URL + feature flags.    |
| `flake.nix`                   | Builds the deployable site (`nix build .#site`) + dev shell. |
| `.github/workflows/check.yml` | PR gate: builds the flake (`nix flake check`).           |
| `.github/workflows/cloudflare-build-debug.yml` | PR gate + manual (`workflow_dispatch`): runs `scripts/cloudflare-build.sh` and verifies its output, mirroring Cloudflare's own build. |
| `scripts/cloudflare-build.sh` | Cloudflare dashboard's Build command — downloads Zola's static binary and builds the site into `public/`. |
| `wrangler.jsonc`              | Cloudflare Workers static-assets config (`public/`).     |
| `CLOUDFLARE_MIGRATION.md`     | Runbook for the GitHub Pages → Cloudflare hosting migration. |
| `archive/`                    | Old, unrelated files kept for history only.              |

## Local development

With [Nix](https://nixos.org) (flakes enabled):

```sh
nix develop              # dev shell: zola, python3, html-tidy
zola serve --root site   # live-reloading preview at http://127.0.0.1:1111

nix build .#site         # produce the deployable tree at ./result
nix run                  # preview the built site at http://localhost:8080
```

## Adding rules chapters

Each chapter of the handbook is one markdown file in `site/content/rules/`:

```markdown
+++
title = "The Chapter's Name"
description = "One line for search engines."
weight = 20            # order in the table of contents (low = first)

[extra]
label = "BOOK ONE"     # optional small tag shown in the TOC and page header
+++

The chapter text, in ordinary markdown. **Bold**, *italics*, headings
(`##`), lists, and blockquotes are all styled to match the site.
```

Commit, push, merge — the section index at `/rules/` picks the chapter up
automatically, ordered by `weight`. The section intro text lives in
`site/content/rules/_index.md`.

## The Archive (`/archive/`)

The Archive is the development record of the Council **system** — the drafts,
rulings, and books in the order they were made. Each entry is browsable in the
tab (the original self-contained `.dc.html`) and downloadable as a Letter-size
PDF.

The Atlantis **Council of Un** campaign layer is deliberately kept out of the
Archive (the campaign stays separate from the system). Don't add campaign
documents here.

**To add an archived document:**

1. Drop the `.dc.html` in `site/static/archive/docs/` (it loads `./support.js`,
   which is already there — one shared copy; the print editions also use
   `./doc-page.js`) and the matching `.pdf` in `site/static/archive/pdf/`.
2. Add one entry to the right era in `site/data/archive.toml`:

   ```toml
     [[era.doc]]
     title = "The document's name"
     desc  = "One line describing it."
     html  = "26_My_New_Doc.dc.html"
     pdf   = "26_My_New_Doc.pdf"      # optional
     tag   = "SUPERSEDED"             # optional: SUPERSEDED / HISTORICAL / KEEPER-ONLY
   ```

The `/archive/` index renders straight from that file, grouped by era.

## Work timeline (landing page)

The landing page shows a timeline of what has been built — a compact horizontal
strip of status-coloured nodes pinned above the hero (click a node to jump to its
full entry), and the full vertical timeline further down. Both render from the same
**`site/data/timeline.toml`** — that file is the single source the site reads at
build time:

```toml
[[milestone]]
when    = "Now"                       # free label: a month, a date, "Now" / "Next" / "Later"
title   = "Revising the Handbook"
status  = "active"                    # done | active | planned
summary = "One or two sentences on the work."
  [[milestone.link]]                  # optional links (into /archive/, /rules/, /un/)
  label = "The Handbook"
  url   = "rules/"                     # site-relative path, passed through get_url
```

`status` drives the badge and node colour (`done` = brass, `active` = lit,
`planned` = muted). Keep entries top-to-bottom oldest-to-newest.

**The tracker is GitHub Issues; this file is its committed mirror.** Issues
labelled `timeline` are the human-facing tracker (manage them in GitHub with the
`status:done` / `status:active` / `status:planned` labels). The site itself only
reads `timeline.toml`, so after changing issues, regenerate the file from them —
the simplest way is to ask Claude Code to **"sync the timeline"**, which reads
the `timeline`-labelled issues and rewrites `timeline.toml` to match. (An
optional CI step could do this automatically on a schedule; it is intentionally
not wired up yet to avoid extra tokens/permissions.)

## Interactive elements (Council of Un)

Un widgets are plain ES modules under `site/static/js/un/`. Each one mounts on
a `data-widget="…"` element and imports `config` from `/js/council-config.js`.
All network use must be gated on `config.apiBaseUrl` (currently `null` —
local-only, localStorage for persistence). When a backend exists, point
`apiBaseUrl` at it and flip the relevant feature flag; nothing else moves.

## Deployment

Hosting is **Cloudflare Workers (static assets)**, via Cloudflare's own
dashboard-connected Git integration — every push to `main` triggers a
Cloudflare build directly, no GitHub Actions involved in the deploy itself.
Its **Build command** is `bash scripts/cloudflare-build.sh`, which
downloads Zola's static binary (Cloudflare's build image has no Nix) and
runs `zola build`, producing `public/` for `wrangler.jsonc`'s
`assets.directory`. `.github/workflows/cloudflare-build-debug.yml` runs
that same script on every PR to catch regressions (e.g. a Zola version
bump) before they reach Cloudflare, and can be run manually to debug a
Cloudflare build failure. `.github/workflows/check.yml` remains as the
separate PR build gate for the Nix flake (`nix flake check`), unrelated to
hosting.

This replaces the previous GitHub Pages setup (`deploy.yml` +
`site/static/CNAME`, both removed). See
[`CLOUDFLARE_MIGRATION.md`](CLOUDFLARE_MIGRATION.md) for the full cutover
runbook and current status — the repo-side changes are in; the Cloudflare
dashboard build-command settings, custom domain, and DNS cutover are manual
follow-up.
