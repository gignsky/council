# Council

The public site for **Council** — a diceless, narrative-first tabletop
roleplaying game, "played with words, not dice." Live at
**[fuckinphilosophers.com](https://fuckinphilosophers.com)**.

The site has three sections:

- **`/`** — the main landing page.
- **`/rules/`** — **The Handbook**: the rules of the game, one markdown file
  per chapter.
- **`/un/`** — **Council of Un**, the personal campaign corner, with its own
  visual identity and (eventually) interactive table tools.

## Layout

| Path                          | What it is                                               |
| ----------------------------- | -------------------------------------------------------- |
| `site/`                       | The [Zola](https://www.getzola.org) project.             |
| `site/content/`               | Pages (`_index.md` → `/`, `un/_index.md` → `/un/`).      |
| `site/templates/`             | Tera templates; `base.html` is the shared skeleton.      |
| `site/static/`                | Copied verbatim to the output root (`CNAME`, css, js).   |
| `site/static/js/council-config.js` | The backend seam — API base URL + feature flags.    |
| `flake.nix`                   | Builds the deployable site (`nix build .#site`) + dev shell. |
| `.github/workflows/deploy.yml`| Builds the flake output and publishes it to GitHub Pages.|
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

## Interactive elements (Council of Un)

Un widgets are plain ES modules under `site/static/js/un/`. Each one mounts on
a `data-widget="…"` element and imports `config` from `/js/council-config.js`.
All network use must be gated on `config.apiBaseUrl` (currently `null` —
local-only, localStorage for persistence). When a backend exists, point
`apiBaseUrl` at it and flip the relevant feature flag; nothing else moves.

## Deployment

Every push to `main` (typically by merging a PR) triggers the
**Deploy site to GitHub Pages** workflow, which runs `nix build .#site` and
publishes the result to GitHub Pages. The build hard-fails if `CNAME`,
`/un/index.html`, or the stylesheets are missing from the output.
`site/static/CNAME` binds the custom domain `fuckinphilosophers.com`.

DNS (Cloudflare) is already configured: apex `A`/`AAAA` records to GitHub
Pages, `www` CNAME to `gignsky.github.io`, all DNS-only, SSL/TLS mode **Full**.
Pages is configured with Source = "GitHub Actions" and the custom domain set.
