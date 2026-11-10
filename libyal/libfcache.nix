{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcdata
, libcerror
, libcthreads
}:

stdenv.mkDerivation rec {
  pname = "libfcache";
  version = "20260520";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfcache";
    rev = version;
    hash = "sha256-aKYFFrN+K9DH7SJ37FDUodO8PwEU8GeqYu5WDAD1n5w=";
  };

  postPatch = ''
    sed -i '/libcdata/d' Makefile.am
    sed -i '/libcdata\/Makefile/d' configure.ac
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
    libcdata
    libcerror
    libcthreads
  ];

  meta = with lib; {
    description = "libyal's library for cross platform generic (data) cache functions";
    homepage = "https://github.com/libyal/libfcache";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
