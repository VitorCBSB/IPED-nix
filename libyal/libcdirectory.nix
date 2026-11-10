{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libclocale
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libcdirectory";
  version = "20260703";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcdirectory";
    rev = version;
    hash = "sha256-N/Gh5M2pLESe8ZYEQW6xoG/9xuW+W9RDWivm/ahmRbE=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libclocale/d' Makefile.am
    sed -i '/libclocale\/Makefile/d' configure.ac
    sed -i '/libuna/d' Makefile.am
    sed -i '/libuna\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
    libclocale
    libuna
  ];

  meta = with lib; {
    description = "libyal's cross platform directory functions";
    homepage = "https://github.com/libyal/libcdirectory";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
