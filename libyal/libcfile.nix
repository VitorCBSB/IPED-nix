{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libclocale
, libcnotify
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libcfile";
  version = "20260704";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcfile";
    rev = version;
    hash = "sha256-CXjeuFZYNJQn8zhNvmptYOeJETuD2Iop3CikDFGfY7c=";
  };

  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libclocale/d' Makefile.am
    sed -i '/libclocale\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
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
    libcnotify
    libuna
  ];

  meta = with lib; {
    description = "libyal's cross platform file functions";
    homepage = "https://github.com/libyal/libcfile";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
