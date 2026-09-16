{
  description = "Council — the landis.fish static site (Zola)";

  inputs = {
    nixpkgs.url = "github:gignsky/gigpkgs/gigpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Every page the deploy is allowed to be missing zero of. Shared by the
        # derivation's installPhase and the council-verify dev-shell command so
        # the two can't drift apart.
        requiredFiles = [
          "index.html"
          "un/index.html"
          "rules/index.html"
          "404.html"
          "archive/index.html"
          "archive/docs/support.js"
          "archive/docs/15_Foundations_FINAL.dc.html"
          "archive/pdf/15_Foundations_FINAL.pdf"
          "css/main.css"
          "css/un.css"
          "js/council-config.js"
        ];

        # The whole deployable site: Zola renders site/ (landing + work timeline
        # at /, the Handbook at /rules/, the development Archive at /archive/,
        # Council of Un at /un/) into a $out tree ready to hand to Cloudflare
        # verbatim. static/ files — including the archived documents — land at
        # the root.
        council-site = pkgs.stdenvNoCC.mkDerivation {
          pname = "council-site";
          version = "0.3.0";

          src = ./site;

          nativeBuildInputs = [
            pkgs.zola
            pkgs.html-tidy
            pkgs.cacert
          ];

          # Zola's load_data() builds a reqwest client up front, even for the
          # purely local data/*.toml loads in templates/. Inside the Nix sandbox
          # there is no system CA bundle, so that client build panics
          # ("No CA certificates were loaded from the system") and takes the
          # whole site build down with it. Point it at cacert's bundle.
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

          buildPhase = ''
            runHook preBuild
            zola build --output-dir $out
            runHook postBuild
          '';

          # Hard guarantees the deploy depends on; a cosmetic tidy warning
          # stays non-fatal, a missing section does not.
          installPhase = ''
            runHook preInstall
            for f in ${pkgs.lib.escapeShellArgs requiredFiles}; do
              test -f "$out/$f" || { echo "missing: $f" >&2; exit 1; }
            done
            grep -q COUNCIL $out/index.html
            echo "Linting generated HTML..."
            tidy -q -e $out/index.html || echo "tidy reported warnings (non-fatal)"
            tidy -q -e $out/un/index.html || echo "tidy reported warnings (non-fatal)"
            runHook postInstall
          '';

          meta = {
            description = "Council site for landis.fish (also served at landis.fish)";
            homepage = "https://landis.fish";
          };
        };

        # Locates the repo root so the dev-shell verbs work from any
        # subdirectory rather than only from the top level.
        siteRoot = pkgs.writeShellScript "council-site-root" ''
          root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || pwd)"
          if [ ! -f "$root/site/config.toml" ]; then
            echo "council: can't find site/config.toml under $root" >&2
            exit 1
          fi
          printf '%s\n' "$root"
        '';

        # Zola takes --root as a *global* flag, before the subcommand; spelled
        # the other way round it exits with "unexpected argument '--root'
        # found". These wrappers get it right once so it doesn't have to be
        # retyped by hand.
        council-build = pkgs.writeShellScriptBin "council-build" ''
          set -euo pipefail
          root="$(${siteRoot})"
          exec ${pkgs.zola}/bin/zola --root "$root/site" build "$@"
        '';

        council-serve = pkgs.writeShellScriptBin "council-serve" ''
          set -euo pipefail
          root="$(${siteRoot})"
          exec ${pkgs.zola}/bin/zola --root "$root/site" serve "$@"
        '';

        # The same assertions the derivation's installPhase enforces, runnable
        # against a local build so a missing page surfaces before CI.
        council-verify = pkgs.writeShellScriptBin "council-verify" ''
          set -euo pipefail
          root="$(${siteRoot})"
          out="''${1:-$root/site/public}"
          if [ ! -d "$out" ]; then
            echo "council: no build at $out — run council-build first" >&2
            exit 1
          fi
          status=0
          for f in ${pkgs.lib.escapeShellArgs requiredFiles}; do
            if [ -f "$out/$f" ]; then
              echo "  ok      $f"
            else
              echo "  MISSING $f" >&2
              status=1
            fi
          done
          if ${pkgs.gnugrep}/bin/grep -q COUNCIL "$out/index.html"; then
            echo "  ok      index.html contains COUNCIL"
          else
            echo "  MISSING COUNCIL marker in index.html" >&2
            status=1
          fi
          ${pkgs.html-tidy}/bin/tidy -q -e "$out/index.html" \
            || echo "  tidy reported warnings (non-fatal)"
          exit $status
        '';
      in
      {
        packages.default = council-site;
        packages.site = council-site;

        # `nix flake check` (run by CI on every PR) builds the site and its
        # assertions.
        checks.site = council-site;

        # `nix run` spins up a throwaway local preview of the built site.
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "serve-council" ''
            exec ${pkgs.python3}/bin/python3 -m http.server 8080 \
              --directory ${council-site}
          ''}";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.zola
            pkgs.python3
            pkgs.git
            pkgs.html-tidy
            pkgs.roll-flow
            council-build
            council-serve
            council-verify
          ];

          # Matches the derivation: zola's load_data() wants a CA bundle even
          # for local data/*.toml, and a shell entered from a non-NixOS host may
          # not have one set.
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

          shellHook = ''
            echo "  Council dev shell"
            echo
            echo "  council-build     compile the site to site/public/"
            echo "  council-serve     live preview on http://127.0.0.1:1111"
            echo "  council-verify    check a build for the pages deploy needs"
            echo
            echo "  nix build .#site  sandboxed build (what CI runs)"
            echo "  nix run           serve that build on :8080"
          '';
        };
      }
    );
}
