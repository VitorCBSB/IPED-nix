{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libcthreads
}:

stdenv.mkDerivation rec {
  pname = "libcdata";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcdata";
    rev = version;
    hash = "sha256-6Ao4qL1ieGI6eozy8lQGZpMmvCivzrTSyuL0AQzswG4=";
  };

  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcthreads/d' Makefile.am
    sed -i '/libcthreads\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
    libcthreads
  ];

  meta = with lib; {
    description = "libyal's library for cross platform C generic data functions";
    homepage = "https://github.com/libyal/libcdata";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}



