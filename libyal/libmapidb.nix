{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libcnotify
}:

stdenv.mkDerivation rec {
  pname = "libmapidb";
  version = "20240420";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libmapidb";
    rev = version;
    hash = "sha256-IrclFLaQ478mNdhcUzfi6Kqa+1USdwqACPzadcui9S8=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
    libcnotify
  ];

  meta = with lib; {
    description = "libyal's library for MAPI database definitions";
    homepage = "https://github.com/libyal/libmapidb";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
