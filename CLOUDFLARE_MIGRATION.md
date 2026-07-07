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
`nix build .#site`. `wrangler.jsonc`'s `assets.directory` points at the
**built** output directory (`public`, matching what `deploy.yml` used to
produce), not at `site/` itself.

**The build happens in GitHub Actions, not Cloudflare's own Git
integration.** Cloudflare's dashboard-connected build was tried first and
failed: its build container has no Nix, and with no build command
configured it runs straight to `npx wrangler versions upload` against a raw
checkout, which fails because `public/` doesn't exist yet (see
`.github/workflows/cloudflare-build-debug.yml`, which reproduces that exact
failure on demand for future debugging). Rather than fight Cloudflare's
build image for Nix support, `.github/workflows/cloudflare-deploy.yml` reuses
the same Nix setup `check.yml` already proves works, builds `public/`, and
pushes it straight to Cloudflare via `wrangler deploy` (the
`cloudflare/wrangler-action`), authenticated with a `CLOUDFLARE_API_TOKEN` +
`CLOUDFLARE_ACCOUNT_ID` repo secret pair.

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

- [X] ~~Cloudflare dashboard → Workers & Pages → Create application →
  Import a repository~~ — tried first, abandoned. Cloudflare's build
  container has no Nix and, with no build command configured, ran straight
  to `npx wrangler versions upload` against an unbuilt checkout, which
  fails because `public/` doesn't exist
  ([build log](https://dash.cloudflare.com/57c1756e8503ae036a9c939d1f174c88/workers/services/view/council/production/builds/464c6a92-cee1-4773-9d63-ac30ea483085)).
  Reproducible on demand via `.github/workflows/cloudflare-build-debug.yml`
  (`workflow_dispatch`).
- [ ] Instead: `.github/workflows/cloudflare-deploy.yml` builds via Nix
  (same setup as `check.yml`) and deploys with `wrangler deploy` on every
  push to `main`. Before it can run, add two repo secrets (GitHub repo →
  **Settings → Secrets and variables → Actions**):
  - `CLOUDFLARE_API_TOKEN` — a Cloudflare API token scoped to
    **Workers Scripts:Edit** (and **Account Settings:Read** if account-level
    reads are needed) for the account holding `fuckinphilosophers.com`.
    Create one under **My Profile → API Tokens → Create Token** in the
    Cloudflare dashboard.
  - `CLOUDFLARE_ACCOUNT_ID` — the account ID shown on the Cloudflare
    dashboard's right sidebar for that account.
  `wrangler deploy` creates the `council` Worker on first run if it doesn't
  already exist — no separate "Create application" dashboard step needed.
- [ ] If a Cloudflare dashboard project named `council` already exists from
  the abandoned attempt above, disable its Git integration (Worker →
  **Settings → Build**) so it stops polling/failing on every push and
  doesn't race this workflow's deploys.
- [ ] Trigger the workflow (push to `main`, or **Actions → Deploy site to
  Cloudflare Workers → Run workflow**) and confirm it deploys successfully.

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
  `cloudflare-deploy.yml`, Nix-built and pushed with `wrangler deploy`).
  `check.yml` is kept — it's the Nix flake build gate for PRs and is
  unrelated to hosting.
- [X] Delete `site/static/CNAME` (GitHub-Pages-specific, now vestigial)

The dashboard half is still manual follow-up, and should happen only after
Phase 3's DNS cutover is confirmed stable:

- [ ] GitHub repo → **Settings → Pages** → remove the custom domain /
  disable Pages
- [ ] Push a trivial change and confirm `cloudflare-deploy.yml` still
  deploys successfully

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
- [ ] Push-to-deploy works end-to-end via `cloudflare-deploy.yml`
- [X] Old GitHub Pages workflow removed, `site/static/CNAME` deleted

## Cloudflare vs. GitHub Pages, in short

| | GitHub Pages | Cloudflare (Workers static assets) |
| --- | --- | --- |
| Private repos | Requires a paid GitHub plan | Free, via GitHub App integration |
| Compute model | Static files only | Static files, with room to add edge logic (redirects, headers, auth) later |
| Custom domain + HTTPS | Free, automatic, but needs DNS-only (unproxied) records for GitHub's own cert issuance | Free, automatic; Cloudflare issues/manages the cert and expects the record proxied |
| Build system | GitHub Actions artifact upload (what this repo did before this PR) | GitHub Actions builds via Nix, pushes via `wrangler deploy` (Cloudflare's own Nix-less Git integration build doesn't work here) |
| PR previews | None built in | Every branch/PR gets its own preview URL automatically |
| Rollback | Only "latest deploy"; recover by re-running an old workflow run | Prior deployments are kept; instant rollback from the dashboard |
| Cost | Free | Free at this scale |
