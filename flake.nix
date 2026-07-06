{
  description = "Council — the fuckinphilosophers.com static landing site";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # The whole deployable site. Building this derivation "outputs" the
        # landing page (index.html + CNAME, and whatever gets added under
        # site/ later — e.g. the handbook books) into a single $out tree that
        # is ready to be served or handed to GitHub Pages verbatim.
        council-site = pkgs.stdenvNoCC.mkDerivation {
          pname = "council-site";
          version = "0.1.0";

          src = ./site;

          nativeBuildInputs = [ pkgs.html-tidy ];

          # Lint the markup, but never let a cosmetic warning fail the deploy.
          buildPhase = ''
            runHook preBuild
            echo "Checking index.html markup..."
            tidy -q -e index.html || echo "tidy reported warnings (non-fatal)"
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r ./. $out/
            runHook postInstall
          '';

          meta = {
            description = "Council landing page for fuckinphilosophers.com";
            homepage = "https://fuckinphilosophers.com";
          };
        };
      in
      {
        packages.default = council-site;
        packages.site = council-site;

        # `nix run` spins up a throwaway local preview of the built site.
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "serve-council" ''
            exec ${pkgs.python3}/bin/python3 -m http.server 8080 \
              --directory ${council-site}
          ''}";
        };

        # Dev shell, ready for the handbook work to come.
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            python3
            git
            html-tidy
          ];
          shellHook = ''
            echo "  Council dev shell"
            echo "  live preview:   npx live-server site   (or: nix run)"
            echo "  build output:   nix build .#site"
          '';
        };
      });
}
