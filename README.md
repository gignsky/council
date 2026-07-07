# Council

The public site for **Council** — a diceless, narrative-first tabletop
roleplaying game, "played with words, not dice." Live at
**[fuckinphilosophers.com](https://fuckinphilosophers.com)**.

The site has two sections:

- **`/`** — the main site about Council the game (landing page now; rules,
  handbook books, and lore to come).
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
