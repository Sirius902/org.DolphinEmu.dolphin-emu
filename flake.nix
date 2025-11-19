{
  description = "Dolphin flatpak dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = {pkgs, ...}: let
        buildInputs = [
          pkgs.appstream
          pkgs.flatpak-builder
        ];
      in {
        formatter = pkgs.alejandra;

        packages.build = pkgs.writeShellApplication {
          name = "build";

          runtimeInputs = buildInputs;

          text = ''
            flatpak-builder --user --install --force-clean build org.DolphinEmu.dolphin-emu.yml
          '';
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = buildInputs;
        };
      };
    };
}
