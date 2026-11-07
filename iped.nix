# iped.nix  (callPackage this)
{ lib, stdenv, fetchzip, makeWrapper, jdk, sleuthkit-iped
, toolsBin ? [ ], toolsLib ? [ ], toolsPythonPath ? [ ], coreutils, gnused, gnugrep }:

stdenv.mkDerivation rec {
  pname = "iped";
  version = "4.3.1";

  src = fetchzip {
    url = "https://github.com/sepinf-inc/IPED/releases/download/${version}/IPED-${version}_and_java_plugins.zip";
    stripRoot = false;
    hash = "sha256-PjKQxD2BUEio1yPITdb23NaWq2R6oxZNFjlABV52rDo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/iped $out/libexec $out/bin
    cp -r iped-${version}/. $out/share/iped

    cat > $out/libexec/iped-launcher <<'EOF'
    set -eu
    share="@share@"
    data="''${XDG_DATA_HOME:-$HOME/.local/share}/iped/@version@"
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/iped"

    if [ ! -e "$data/.installed" ]; then
      mkdir -p "$data"
      cp -r --no-preserve=mode,ownership "$share"/. "$data"/
      touch "$data/.installed"
    fi
    if [ -d "$cfg" ]; then
      cp -r --no-preserve=mode,ownership "$cfg"/. "$data"/
    fi
    sed -i '/^#\?[[:space:]]*tskJarPath/d' "$data/LocalConfig.txt" 2>/dev/null || true
    echo "tskJarPath = @tskjar@" >> "$data/LocalConfig.txt"

    exec @java@/bin/java -jar "$data/iped.jar" "$@"
    EOF

    substituteInPlace $out/libexec/iped-launcher \
      --replace-fail @share@ $out/share/iped \
      --replace-fail @version@ ${version} \
      --replace-fail @tskjar@ ${sleuthkit-iped}/share/java/sleuthkit.jar \
      --replace-fail @java@ ${jdk}
    chmod +x $out/libexec/iped-launcher

    makeWrapper ${stdenv.shell} $out/bin/iped \
      --add-flags $out/libexec/iped-launcher \
      --prefix PATH : ${lib.makeBinPath ([ jdk coreutils gnused gnugrep ] ++ toolsBin)} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath ([ sleuthkit-iped ] ++ toolsLib)} \
      --set SAL_USE_VCLPLUGIN gtk
  '';
}

