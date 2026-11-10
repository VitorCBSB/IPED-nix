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
  pname = "libcdatetime";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcdatetime";
    rev = version;
    hash = "sha256-H88so+gmjk0AgLwGq90aI0OAN+zWBg1jX3FnbV6FFkk=";
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
    description = "libyal's library for cross platform C date and time functions";
    homepage = "https://github.com/libyal/libcdatetime";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}



