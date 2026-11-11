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

    # The zip also has a top-level plugins/ directory with optional GPL-licensed jars
    # (DBX decoder, Telegram decoder, Stanford CoreNLP). IPED loads them from the
    # plugins/ folder inside its own root.
    mkdir -p $out/share/iped/plugins
    cp -r plugins/. $out/share/iped/plugins/

    cat > $out/libexec/iped-launcher <<'EOF'
    set -eu
    share="@share@"
    data="''${XDG_DATA_HOME:-$HOME/.local/share}/iped/@version@"
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/iped"

    # (Re)copy the release into the working copy when it does not exist yet or when
    # the package has changed (the stamp holds the store path of the copied release).
    # -f: files copied earlier from the (read-only) store keep mode 0444, which would
    # otherwise make the copy fail with "Permission denied".
    stamp="$data/.installed"
    if [ "$(cat "$stamp" 2>/dev/null)" != "$share" ]; then
      mkdir -p "$data"
      cp -rf --no-preserve=mode,ownership "$share"/. "$data"/
      echo "$share" > "$stamp"
    fi
    if [ -d "$cfg" ]; then
      cp -rf --no-preserve=mode,ownership "$cfg"/. "$data"/
    fi
    # The release's LocalConfig.txt does not end with a newline, so a plain append would
    # glue the new text onto its last line (pluginFolder = ../plugins/tskJarPath = ...).
    sed -i -e '$a\' "$data/LocalConfig.txt" 2>/dev/null || true
    sed -i -e '/^#\?[[:space:]]*tskJarPath/d' -e '/^[[:space:]]*pluginFolder/d' "$data/LocalConfig.txt" 2>/dev/null || true
    {
      echo "tskJarPath = @tskjar@"
      echo "pluginFolder = plugins"
    } >> "$data/LocalConfig.txt"

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

