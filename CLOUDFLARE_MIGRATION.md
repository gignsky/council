# Migrating hosting to Cloudflare (Workers + static assets)

This is the runbook for moving `fuckinphilosophers.com` off GitHub Pages
onto **Cloudflare Workers with static assets**, following the same pattern
already used for [cashconsults-website](https://github.com/gignsky/cashconsults-website).

Cloudflare Pages still works, but as of 2026 it's in maintenance mode —
Cloudflare is steering all new and migrating static sites to Workers with
static assets instead, which now has full parity (custom domains, automatic
HTTPS, private-repo Git integration, same free tier). That's the target
here, not classic Pages.

Unlike cashconsults' `site/` (pre-built static HTML, deployable as-is),
council's `site/` is **Zola source** — the deployable tree only exists after
`nix build .#site`. So the Cloudflare project needs an explicit build
command, and `wrangler.jsonc`'s `assets.directory` points at the **built**
output directory (`public`, matching what `deploy.yml` used to produce),
not at `site/` itself.

The steps below are almost entirely manual dashboard/DNS actions on the
Cloudflare account that holds the `fuckinphilosophers.com` zone — they can't
be scripted from this repo, so this file is the checklist to work through by
hand, and to track progress against. **This repo's own changes (config,
removing the GitHub Pages workflow and CNAME) are already done as of this
PR — the dashboard/DNS phases below are the manual follow-up still owed
before the migration is actually live.**

## Why this can be zero-downtime

DNS for `fuckinphilosophers.com` already lives on Cloudflare: apex
`A`/`AAAA` records point at GitHub Pages' IPs today, `www` CNAMEs to
`gignsky.github.io`, all DNS-only, SSL/TLS mode Full. Moving hosting to
Cloudflare means the cutover is a same-provider DNS record edit, not a
cross-registrar migration, so the switch propagates across Cloudflare's edge
almost immediately instead of waiting on external resolver TTLs.

## Phase 1 — Stand up Cloudflare, verify in isolation

No production DNS changes in this phase — zero risk.

- [ ] Cloudflare dashboard → **Workers & Pages → Create application →
  Import a repository** → connect the GitHub account/App to
  `gignsky/council`
- [ ] Project config:
  - Build command:
    `nix build .#site --print-build-logs && rm -rf public && cp -rL result public && chmod -R u+w public`
    (mirrors `deploy.yml`'s steps exactly — Nix isn't a default supported
    builder on Cloudflare, so this needs to be validated once against the
    dashboard's build image; if Cloudflare's build environment can't run
    Nix, fall back to building via GitHub Actions and using
    `wrangler deploy` / `wrangler pages deploy` to push the pre-built
    `public/` artifact instead)
  - Output/assets directory: `public`
  - Root directory: repo root (`wrangler.jsonc` already declares
    `assets.directory: "public"`)
- [ ] Save and deploy

### Troubleshooting: Worker name conflict on first deploy

cashconsults hit this and council likely will too: if Cloudflare's first
build runs before `wrangler.jsonc` has landed on `main` (e.g. testing this
PR's branch before merge), the checkout has no config file, so
`wrangler deploy` bootstraps a brand-new one and tries to create a Worker
named `council` — which may already exist from project setup — and
Cloudflare's safety check refuses to overwrite it:

```
✘ [ERROR] A Worker named "council" already exists in your account. This
deploy could not confirm that it should update that Worker, so it stopped
instead of overwriting it. To update the existing Worker, add a Wrangler
configuration file naming "council"; to deploy separately, use a different
name.
```

Fix (dashboard-only, no repo push needed):

- [ ] Worker → **Settings → Build → Branch control** → temporarily set the
  production branch to this PR's branch until it's merged to `main`
- [ ] Trigger a new deployment (push, or **Deployments → Retry/Create
  deployment**)
- [ ] Confirm the build log reads the existing `wrangler.jsonc` (no
  "📄 Create wrangler.jsonc:" step) and deploys without the name-conflict
  error
- [ ] Once confirmed green, point the production branch back to `main`

## Phase 2 — Prove the custom domain + HTTPS work before touching production DNS

- [ ] *(Optional, recommended)* Add a throwaway proxied CNAME, e.g.
  `cfcheck.fuckinphilosophers.com` → the Worker, and confirm HTTPS + correct
  rendering there first.
- [ ] Worker → **Settings → Domains & Routes → add custom domain**:
  `fuckinphilosophers.com` (and `www.fuckinphilosophers.com` if it should
  resolve directly too). Cloudflare provisions the certificate
  automatically — it's already the DNS authority for the zone, so
  validation is immediate.
- [ ] Cloudflare will flag the existing apex A/AAAA records (GitHub Pages
  IPs) and the `www` CNAME (`gignsky.github.io`) as conflicting.
  **Don't let it auto-overwrite yet.** Wait until the new cert shows
  **Active** while the old records are still live and still serving GitHub
  Pages traffic.

## Phase 3 — Zero-downtime cutover

- [ ] Lower the TTL on the apex/`www` records first if they aren't already
  low; pick a low-traffic window.
- [ ] In the Cloudflare DNS zone, replace:
  - Apex `fuckinphilosophers.com` A/AAAA (GitHub Pages IPs) → proxied
    CNAME/flattened record to the Worker's custom-domain target (Cloudflare
    flattens CNAMEs at the apex automatically).
  - `www` CNAME (`gignsky.github.io`) → proxied CNAME to the same target.
- [ ] Verify immediately:
  ```sh
  curl -I https://fuckinphilosophers.com
  curl -I https://www.fuckinphilosophers.com
  curl -v https://fuckinphilosophers.com   # eyeball the cert chain
  ```
  Both should return `200` with a valid cert. Also do a manual browser check
  for mixed-content/HSTS issues.
- [ ] Enable **Always Use HTTPS**; confirm minimum TLS version matches what
  the zone had before.
- [ ] Monitor for ~15–30 minutes before calling the cutover done.

## Phase 4 — Decommission GitHub Pages

The repo-side half of this phase is **already done in this PR**:

- [X] Remove `.github/workflows/deploy.yml` (deploy now happens via
  Cloudflare's Git integration). `check.yml` is kept — it's the Nix flake
  build gate for PRs and is unrelated to hosting.
- [X] Delete `site/static/CNAME` (GitHub-Pages-specific, now vestigial)

The dashboard half is still manual follow-up, and should happen only after
Phase 3's DNS cutover is confirmed stable:

- [ ] GitHub repo → **Settings → Pages** → remove the custom domain /
  disable Pages
- [ ] Confirm Cloudflare's GitHub App still has access to the repo (GitHub →
  **Settings → Integrations → GitHub Apps**)
- [ ] Push a trivial change and confirm Cloudflare's Git integration still
  auto-deploys

## Rollback

At any point after the Phase 3 DNS swap and before Phase 4's GitHub Pages
removal, reverting is just restoring the apex A/AAAA and `www` CNAME to
their prior GitHub Pages values (Cloudflare's DNS history / activity log
has the prior record values) — GitHub Pages is still fully configured and
able to serve immediately since it isn't disabled until Phase 4.

If something goes wrong **after this PR merges but before Phase 1 is even
started**, note that `deploy.yml` and `site/static/CNAME` are gone from
`main` at that point — restoring GitHub Pages service means reverting this
PR's commit (or re-adding those two files) in addition to the DNS rollback
above.

## Verification checklist

- [ ] `*.workers.dev` preview renders identically to current production
- [ ] Throwaway `cfcheck.fuckinphilosophers.com` serves via Cloudflare with
  valid HTTPS
- [ ] Custom domain cert for `fuckinphilosophers.com` shows **Active**
  before DNS cutover
- [ ] Post-cutover: apex and `www` both return 200 with valid certs
- [ ] No mixed-content warnings; Un widgets' inlined JS still runs correctly
- [ ] Push-to-deploy works end-to-end from Cloudflare's Git integration
- [X] Old GitHub Pages workflow removed, `site/static/CNAME` deleted

## Cloudflare vs. GitHub Pages, in short

| | GitHub Pages | Cloudflare (Workers static assets) |
| --- | --- | --- |
| Private repos | Requires a paid GitHub plan | Free, via GitHub App integration |
| Compute model | Static files only | Static files, with room to add edge logic (redirects, headers, auth) later |
| Custom domain + HTTPS | Free, automatic, but needs DNS-only (unproxied) records for GitHub's own cert issuance | Free, automatic; Cloudflare issues/manages the cert and expects the record proxied |
| Build system | GitHub Actions artifact upload (what this repo did before this PR) | Cloudflare-native Git integration (Nix build command), or a pre-built artifact pushed via `wrangler deploy` |
| PR previews | None built in | Every branch/PR gets its own preview URL automatically |
| Rollback | Only "latest deploy"; recover by re-running an old workflow run | Prior deployments are kept; instant rollback from the dashboard |
| Cost | Free | Free at this scale |
