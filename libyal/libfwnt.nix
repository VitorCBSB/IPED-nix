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
}:

stdenv.mkDerivation rec {
  pname = "libfwnt";
  version = "20260602";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfwnt";
    rev = version;
    hash = "sha256-0RPehbXOLPqgbqNJEQQR7PxhPztluejwp46v/CfFv0E=";
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
  ];

  meta = with lib; {
    description = "libyal's library for Windows NT data types";
    homepage = "https://github.com/libyal/libfwnt";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
