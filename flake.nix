{
  description = "IPED (digital forensic tool) packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;

      # Plain JDK 11: builds Sleuthkit's Java bindings and runs IPED's
      # command-line processing (no JavaFX needed there).
      jdk = pkgs.jdk11;

      # Liberica "Full" JDK 11 (bundles JavaFX): used only by the analysis GUI.
      jdkFx = pkgs.callPackage ./liberica-jdk-full.nix { };

      # Optional external tools (OCR, libyal parsers, RegRipper's perl, ...).
      # See tools.nix; anything missing from nixpkgs is skipped with a warning.
      # withWhisper = true adds faster-whisper to the Python environment (local
      # Whisper audio transcription, CPU only; see the README).
      tools = import ./tools.nix { inherit pkgs jdk; withJep = true; withWhisper = true; };

      sleuthkit-iped = pkgs.callPackage ./sleuthkit-iped.nix { inherit jdk; };

      iped = pkgs.callPackage ./iped.nix {
        inherit jdk sleuthkit-iped;
        toolsBin = tools.bin;
        toolsLib = tools.lib;
      };

      # Libraries the Liberica JDK dlopen()s at runtime. They are not declared
      # dependencies of its .so files, so autoPatchelf can't wire them up.
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

        # `nix build .` / `nix profile install .` gives both commands.
        default = pkgs.symlinkJoin {
          name = "iped-with-search";
          paths = [ iped iped-search ];
        };
      };
    };
}
