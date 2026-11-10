{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcdata
, libcerror
, libcnotify
, libcthreads
, libfcache
}:

stdenv.mkDerivation rec {
  pname = "libfdata";
  version = "20260521";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfdata";
    rev = version;
    hash = "sha256-h2Y4Dq/k1n0vdamgf7RVtZx7rqkz0KA++sh4Z1gkYpE=";
  };

  postPatch = ''
    sed -i '/libcdata/d' Makefile.am
    sed -i '/libcdata\/Makefile/d' configure.ac
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
    sed -i '/libcthreads/d' Makefile.am
    sed -i '/libcthreads\/Makefile/d' configure.ac
    sed -i '/libfcache/d' Makefile.am
    sed -i '/libfcache\/Makefile/d' configure.ac
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
    libcnotify
    libcthreads
    libfcache
  ];

  meta = with lib; {
    description = "libyal's library for cross platform generic data functions";
    homepage = "https://github.com/libyal/libfdata";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
