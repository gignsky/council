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

rm -rf public
(cd site && "$workdir/zola" build --output-dir ../public)

rm -rf "$workdir"
