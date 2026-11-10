
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
  pname = "libclocale";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libclocale";
    rev = version;
    hash = "sha256-cxSzf7U26hihXK+Hvczhi2Pu5bVvpskutuDXywOtZ3s=";
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
    description = "libyal's C locale cross platform functions";
    homepage = "https://github.com/libyal/libclocale";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}
