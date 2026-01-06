# PoC flake for dotfiles dev tools
# - Provides a `devShell` containing the CLI tools from Dockerfile.min.slim
# - Provides a `devImage` (OCI image) built with dockerTools
#
# Notes/TODOs:
# - Attribute names are the common ones in nixpkgs; tweak if your channel differs
# - This is a draft. Run `nix flake check` / `nix build .#packages.x86_64-linux.devImage` to validate

{
  description = "PoC flake: devShell + OCI image for dotfiles dev tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Python environment with linters used in Dockerfile.min.slim
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [ mypy flake8 autopep8 isort ]);

        nodePkgs = pkgs.nodePackages;

        # Core CLI tools mirrored from Dockerfile.min.slim. Adjust as needed.
        devTools = with pkgs; [
          git
          jq
          ripgrep
          gnumake
          openssh
          shellcheck
          tflint
          terraform
          terraform-ls
          golangci-lint
          yq
        ];
      in {
        devShells.default = pkgs.mkShell {
          name = "dotfiles-devshell";
          buildInputs = devTools ++ [ pythonEnv nodePkgs.pyright nodePkgs.diagnostic-languageserver ];
          shellHook = ''
            echo "Entering dotfiles devShell — tools available: ${builtins.concatStringsSep ", " (map (p: builtins.toString p) buildInputs)}"
          '';
        };

        packages.${system}.devImage = pkgs.dockerTools.buildImage {
          name = "dotfiles-tools";

          # The image 'contents' are the closure of the listed packages.
          contents = devTools ++ [ pythonEnv nodePkgs.pyright nodePkgs.diagnostic-languageserver ];

          config = {
            Cmd = [ "/bin/sh" ];
            Env = [ "PATH=/bin:/usr/bin" ];
          };

          # Recreate a non-root user (UID 1000) to match typical dev behavior
          extraCommands = ''
            addgroup -g 1000 dev || true
            adduser -D -u 1000 -G dev dev || true
            mkdir -p /home/dev
            chown -R 1000:1000 /home/dev
          '';

          # Keep a simple passthru for debugging/inspection
          passthru = { inherit devTools; };
        };

        # defaultPackage points to the built image (useful for quick `nix build`)
        defaultPackage = self.packages.${system}.devImage;
      }
    );
}
