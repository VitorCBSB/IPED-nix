{
  description = "IPED (digital forensic tool) packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      # GPU transcription for local Whisper (NVIDIA only; tested on an RTX 3050, see the README).
      # Needs the unfree CUDA libraries and compiles CTranslate2 with CUDA locally,
      # which makes the build very slow. Off by default.
      withWhisperGpu = false;

      # Face recognition (IPED's Python task: face_recognition, dlib, OpenCV).
      # UNTESTED; IPED's task may require numpy 1.x, see tools.nix. Off by default.
      withFaceRecognition = false;

      pkgs = import nixpkgs {
        inherit system;
        config = nixpkgs.lib.optionalAttrs withWhisperGpu {
          allowUnfree = true;
          # Only build CUDA code for Ampere cards such as the RTX 3050 (compute
          # capability 8.6). This shortens the build, but the result will not run
          # on GPUs of other generations: remove this line (slower build) or list
          # more capabilities if your machines differ.
          cudaCapabilities = [ "8.6" ];
        };
      };
      lib = pkgs.lib;

      # Plain JDK 11: builds Sleuthkit's Java bindings and runs IPED's
      # command-line processing (no JavaFX needed there).
      jdk = pkgs.jdk11;

      # Liberica "Full" JDK 11 (bundles JavaFX): used only by the analysis GUI.
      jdkFx = pkgs.callPackage ./liberica-jdk-full.nix { };

      # Optional external tools (OCR, libyal parsers, RegRipper's perl, ...).
      # See tools.nix; anything missing from nixpkgs is skipped with a warning.
      # withWhisper = true adds faster-whisper to the Python environment (local
      # Whisper audio transcription, CPU only; see the README). It pulls in large
      # machine-learning dependencies and makes builds much slower; set it to
      # false if you do not need Whisper.
      tools = import ./tools.nix { inherit pkgs jdk; inherit libyalPkgs; withJep = true; withWhisper = true; inherit withWhisperGpu withFaceRecognition; };

      # Libraries that give Sleuthkit more disk-image formats: VMDK, VHD, LVM (libyal)
      # and AFF. nixpkgs packages are preferred; otherwise the release tarballs
      # pinned in libyal-versions.nix are built. Anything unavailable is null, which
      # only leaves that image format unsupported.
      # libyal libraries built from pinned git tags (libyal/ directory)
      libyalPkgs = pkgs.callPackage ./libyal { };

      # libyal libraries from release tarballs (libyal-versions.nix, see update-libyal.sh)
      libyalLocal = import ./libyal-versions.nix (pkgs.callPackage ./libyal.nix { });
      # precedence: git-built libyal/ package, then nixpkgs, then release tarball
      imageLib = name: libyalPkgs.${name} or pkgs.${name} or libyalLocal.${name} or null;

      sleuthkit-iped = pkgs.callPackage ./sleuthkit-iped.nix {
        inherit jdk;
        libbfio = imageLib "libbfio";
        libvmdk = imageLib "libvmdk";
        libvhdi = imageLib "libvhdi";
        libvslvm = imageLib "libvslvm";
        afflib = pkgs.afflib or null;
      };

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
