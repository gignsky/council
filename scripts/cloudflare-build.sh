#!/usr/bin/env bash
# Cloudflare dashboard Build command for this project.
#
# Cloudflare's Git-integration build container has no Nix, so instead of
# `nix build .#site` this downloads Zola directly (it ships as a single
# static binary — no toolchain needed) and runs the same `zola build` step
# by hand, producing the `public/` directory wrangler.jsonc's
# `assets.directory` expects.
#
# Cloudflare dashboard project settings that must match this script:
#   Root directory:          (blank / repo root)
#   Build command:            bash scripts/cloudflare-build.sh
#   Deploy command:            npx wrangler deploy   (default is fine too)
#   Build output/assets dir:  public
set -euo pipefail

ZOLA_VERSION="0.22.1"
ZOLA_TARBALL="zola-v${ZOLA_VERSION}-x86_64-unknown-linux-musl.tar.gz"
ZOLA_URL="https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/${ZOLA_TARBALL}"

workdir="$(mktemp -d)"
curl -fsSL "$ZOLA_URL" | tar xz -C "$workdir"
chmod +x "$workdir/zola"

# Cloudflare Workers Builds exports WORKERS_CI_BRANCH. A build of main is
# production and uses the canonical base_url from site/config.toml; a build
# of any other branch is a preview deployment, so rebuild every absolute
# link against its deterministic Branch Preview URL (the sanitised branch
# name prefixed to the worker's workers.dev host) — otherwise on-site
# navigation jumps from the preview back to frosted-mug.com. Outside
# Cloudflare (local runs, the debug workflow) the variable is unset and the
# production base_url is used, as before.
WORKERS_DEV_HOST="council.maxwellc-rupp2941.workers.dev"
branch="${WORKERS_CI_BRANCH:-main}"
build_args=()
if [ "$branch" != "main" ]; then
  branch_alias="$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')"
  build_args+=(--base-url "https://${branch_alias}-${WORKERS_DEV_HOST}")
fi

rm -rf public
(cd site && "$workdir/zola" build --output-dir ../public ${build_args[@]+"${build_args[@]}"})

rm -rf "$workdir"
