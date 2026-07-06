# Council

The public landing site for **Council** — a diceless, narrative-first tabletop
roleplaying game, "played with words, not dice." Live at
**[fuckinphilosophers.com](https://fuckinphilosophers.com)**.

## Layout

| Path                          | What it is                                              |
| ----------------------------- | ------------------------------------------------------- |
| `site/`                       | The static site source (`index.html`, `CNAME`).         |
| `flake.nix`                   | Builds the deployable site and provides the dev shell.  |
| `.github/workflows/deploy.yml`| Builds the flake output and publishes it to GitHub Pages.|
| `archive/`                    | Old, unrelated files kept for history only.             |

## Local development

With [Nix](https://nixos.org) (flakes enabled):

```sh
nix develop            # dev shell: nodejs, live-server, python3, html-tidy
live-server site       # live-reloading preview

nix build .#site       # produce the deployable tree at ./result
nix run                # preview the built site at http://localhost:8080
```

## Deployment

Every push to `main` (typically by merging a PR) triggers the
**Deploy site to GitHub Pages** workflow, which builds `nix build .#site` and
publishes the result to GitHub Pages. The `site/CNAME` file binds the custom
domain `fuckinphilosophers.com`.

### One-time GitHub setup (human, via the web UI)

1. **Settings → Pages → Build and deployment → Source = "GitHub Actions".**
   The workflow cannot publish until this is set.
2. After the first green run, **Settings → Pages** should show the custom domain
   `fuckinphilosophers.com`; tick **Enforce HTTPS** once the certificate is
   issued.

DNS (Cloudflare) is already configured: apex `A`/`AAAA` records to GitHub Pages,
`www` CNAME to `gignsky.github.io`, all DNS-only, SSL/TLS mode **Full**.
