{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libclocale
, libcsplit
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libcpath";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcpath";
    rev = version;
    hash = "sha256-GE3K7PQBj0KhXvHhdS6/m3XehxORFWRn3NvlUuenpjg=";
  };

  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libclocale/d' Makefile.am
    sed -i '/libclocale\/Makefile/d' configure.ac
    sed -i '/libcsplit/d' Makefile.am
    sed -i '/libcsplit\/Makefile/d' configure.ac
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
    libcsplit
    libuna
  ];

  meta = with lib; {
    description = "libyal's cross platform path functions";
    homepage = "https://github.com/libyal/libcpath";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
