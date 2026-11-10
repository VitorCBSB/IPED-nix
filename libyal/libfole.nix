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
  pname = "libfole";
  version = "20260521";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfole";
    rev = version;
    hash = "sha256-CYLAwujROKUqUUvbukYaugw9lRCGHCHZwDQa/I3hug8=";   # filled in by fill-libyal-pins.sh
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
    description = "libyal's library for OLE data types";
    homepage = "https://github.com/libyal/libfole";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
