{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
}:

stdenv.mkDerivation rec {
  pname = "libfguid";
  version = "20260521";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfguid";
    rev = version;
    hash = "sha256-wv+AB65nP4tjLN4KPCDulpVV0Ts7At/h3V+ZLvLQ/p0=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
  ];

  meta = with lib; {
    description = "libyal's library for cross platform GUID/UUID functions";
    homepage = "https://github.com/libyal/libfguid";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
