{ lib, stdenv, fetchurl, autoPatchelfHook
, alsa-lib, freetype, fontconfig, zlib, gtk3, glib, pango, cairo, gdk-pixbuf, atk
, libGL, libxml2, libxslt, libx11, libxext, libxi, libxrender, libxtst, libxxf86vm
, libxrandr, libxcursor, libxinerama }:

stdenv.mkDerivation {
  pname = "liberica-jdk-full";
  version = "11.0.33.0.3+7";

  src = fetchurl {
    url = "https://download.bell-sw.com/java/11.0.33.0.3+7/bellsoft-jdk11.0.33.0.3+7-linux-amd64-full.tar.gz";
    hash = "sha256-xZomHEWF78B2Qs3Bqk4eHJYyuwI9NiOX5qU1tAxzgWA=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib alsa-lib freetype fontconfig zlib gtk3 glib pango cairo
    gdk-pixbuf atk libGL libxml2 libxslt
    libx11 libxext libxi libxrender libxtst
    libxxf86vm libxrandr libxcursor libxinerama
  ];

  # the JavaFX media plugins target several ffmpeg/gstreamer versions; ignore
  # those at first, then tighten once things run
  autoPatchelfIgnoreMissingDeps = true;

  runtimeDependencies = [
    fontconfig freetype gtk3 glib libGL alsa-lib
    libx11 libxtst libxi libxrender
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = {
    description = "JDK developed by BellSoft.";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.gpl2Only;
  };
}
