{
  description = "Dolphin Emulator Flatpak";

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
        appId = "org.DolphinEmu.dolphin-emu";
        manifest = "${appId}.yml";
        remoteName = "dolphin-dev";

        runtimeInputs = with pkgs; [
          appstream
          flatpak
          flatpak-builder
        ];
      in {
        formatter = pkgs.alejandra;

        packages = {
          build = pkgs.writeShellApplication {
            name = "build";
            inherit runtimeInputs;
            text = ''
              flatpak-builder --user \
                --install-deps-from=flathub \
                --repo=repo \
                build \
                ${manifest}
            '';
          };

          install = pkgs.writeShellApplication {
            name = "install";
            inherit runtimeInputs;
            text = ''
              flatpak --user remote-add --if-not-exists --no-gpg-verify \
                ${remoteName} repo
              flatpak --user install --or-update --noninteractive \
                ${remoteName} ${appId}
            '';
          };

          clean = pkgs.writeShellApplication {
            name = "clean";
            text = ''
              rm -rf build repo .flatpak-builder
            '';
          };
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = runtimeInputs;
        };
      };
    };
}
