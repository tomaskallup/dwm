{
  description = "Build env";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            gcc
            bear
            xorg.libX11.dev
            xorg.libXft
            xorg.libXinerama
          ];

          shellHook = ''
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "dwm-custom";
          version = "6.5.2";
          src = ./.;
          prePatch = ''
              sed -i "s@/usr/local@$out@" config.mk
              rm -f config.h
          '';
          buildInputs = with pkgs; [
            gnumake
            gcc
            xorg.libX11.dev
            xorg.libXft
            xorg.libXinerama
          ];
          patches = [
            "./patches/fancybar.diff" "./patches/functionalgaps.diff" "./patches/cool-autostart.diff"
            "./patches/cursorwarp.diff" "./patches/systray.diff" "./patches/customize.diff"
          ];

          meta = {
            homepage = "https://github.com/tomaskallup/dwm/";
            description = "Dynamic window manager for X";
            longDescription = ''
                dwm is a dynamic window manager for X. It manages windows in tiled,
                monocle and floating layouts. All of the layouts can be applied
                dynamically, optimising the environment for the application in use and the
                task performed.
                Windows are grouped by tags. Each window can be tagged with one or
                multiple tags. Selecting certain tags displays all windows with these
                tags.
            '';
            license = pkgs.lib.licenses.mit;
            maintainers = [];
            platforms = pkgs.lib.platforms.all;
            mainProgram = "dwm";
          };
        };
      });
}
