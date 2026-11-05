# rifiuti2: Windows Recycle Bin analysis tools, used by IPED's RecycleBinParser
# (rifiuti-vista) and RecycleInfo2Parser (rifiuti2).
#
# IPED looks for the commands `rifiuti2` and `rifiuti-vista`. Since version 0.8
# the INFO2 tool is installed as `rifiuti` instead of `rifiuti2`, so a
# `rifiuti2` symlink is added for IPED.
#
# UNTESTED. If the 0.8.2 tag does not exist, try 0.8.1.
{ lib, stdenv, fetchFromGitHub, cmake, ninja, pkg-config, glib }:

stdenv.mkDerivation rec {
  pname = "rifiuti2";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "abelcheung";
    repo = "rifiuti2";
    rev = version;
    hash = "sha256-A6nS77gfr4020icyy5Z7WK3pH8VHinauhoFcJe18YRE=";
  };

  nativeBuildInputs = [ cmake ninja pkg-config ];
  buildInputs = [ glib ];

  postInstall = ''
    if [ ! -e $out/bin/rifiuti2 ] && [ -e $out/bin/rifiuti ]; then
      ln -s rifiuti $out/bin/rifiuti2
    fi
  '';

  meta = {
    description = "Windows Recycle Bin analysis tools";
    homepage = "https://abelcheung.github.io/rifiuti2/";
    platforms = lib.platforms.linux;
  };
}
