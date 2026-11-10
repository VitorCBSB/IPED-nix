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
  pname = "libfdatetime";
  version = "20260521";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfdatetime";
    rev = version;
    hash = "sha256-bMKUysUXDZDxey9muKKksUP30d3IduICsWBuwfhFHFk=";
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
    description = "libyal's library for cross platform date and time values";
    homepage = "https://github.com/libyal/libfdatetime";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
