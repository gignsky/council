{
  description = "Council — the fuckinphilosophers.com static site (Zola)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # The whole deployable site: Zola renders site/ (main landing at /,
        # Council of Un at /un/) into a $out tree ready to hand to GitHub
        # Pages verbatim. static/ files — including CNAME — land at the root.
        council-site = pkgs.stdenvNoCC.mkDerivation {
          pname = "council-site";
          version = "0.2.0";

          src = ./site;

          nativeBuildInputs = [ pkgs.zola pkgs.html-tidy ];

          buildPhase = ''
            runHook preBuild
            zola build --output-dir $out
            runHook postBuild
          '';

          # Hard guarantees the deploy depends on; a cosmetic tidy warning
          # stays non-fatal, a missing CNAME or section does not.
          installPhase = ''
            runHook preInstall
            test -f $out/CNAME
            test -f $out/index.html
            test -f $out/un/index.html
            test -f $out/css/main.css
            test -f $out/css/un.css
            test -f $out/js/council-config.js
            grep -q COUNCIL $out/index.html
            echo "Linting generated HTML..."
            tidy -q -e $out/index.html || echo "tidy reported warnings (non-fatal)"
            tidy -q -e $out/un/index.html || echo "tidy reported warnings (non-fatal)"
            runHook postInstall
          '';

          meta = {
            description = "Council site for fuckinphilosophers.com";
            homepage = "https://fuckinphilosophers.com";
          };
        };
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
          packages = with pkgs; [
            zola
            python3
            git
            html-tidy
          ];
          shellHook = ''
            echo "  Council dev shell"
            echo "  live preview:   zola serve --root site"
            echo "  build output:   nix build .#site"
            echo "  serve output:   nix run"
          '';
        };
      });
}
