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
  pname = "libcsplit";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcsplit";
    rev = version;
    hash = "sha256-3uxEpicHyBo5a3+9SZmoqFXML/oW+mAYJw7x9g9nAr0=";
  };

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
    description = "libyal's library for cross platform C split string functions";
    homepage = "https://github.com/libyal/libcsplit";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}


