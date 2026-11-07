{
  description = "IPED (digital forensic tool) packaged for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;

      jdk = pkgs.jdk11;

      jdkFx = pkgs.callPackage ./liberica-jdk-full.nix { };

      # Optional external tools (OCR, libyal parsers etc.)
      tools = import ./tools.nix { inherit pkgs jdk; withJep = true; };

      sleuthkit-iped = pkgs.callPackage ./sleuthkit-iped.nix { inherit jdk; };

      iped = pkgs.callPackage ./iped.nix {
        inherit jdk sleuthkit-iped;
        toolsBin = tools.bin;
        toolsLib = tools.lib;
        toolsPythonPath = tools.pythonPath;
      };

      guiLibs = with pkgs; [
        fontconfig freetype gtk3 glib pango cairo gdk-pixbuf atk
        libGL alsa-lib
        libx11 libxext libxi libxrender libxtst
      ];

      iped-search = pkgs.writeShellScriptBin "iped-search" ''
        set -eu
        cd "''${1:?usage: iped-search <case-output-folder>}"
        export PATH=${jdkFx}/bin:${lib.makeBinPath tools.bin}:$PATH
        export LD_LIBRARY_PATH=${lib.makeLibraryPath (guiLibs ++ tools.lib)}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        exec java -jar iped/lib/iped-search-app.jar
      '';
    in {
      packages.${system} = {
        inherit sleuthkit-iped iped iped-search;
        default = pkgs.symlinkJoin {
          name = "iped-with-search";
          paths = [ iped iped-search ];
        };
      };
    };
}

