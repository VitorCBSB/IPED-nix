{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libbfio
, libcdata
, libcerror
, libcfile
, libclocale
, libcnotify
, libcpath
, libcsplit
, libcthreads
, libfcache
, libfdata
, libfdatetime
, libfwnt
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libagdb";
  version = "git-20261109";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libagdb";
    rev = "2859755182308c164701f8f8b5688442cb460a8f"; # libagdb has no releases or tags, so we stick to this particular commit (Oct 31, 2026)
    hash = "sha256-lVhgnF2D9mD64aOVSMK9mYwrlq8GLRelmSSgSfQvObU=";
  };

  postPatch = ''
    sed -i '/libbfio/d' Makefile.am
    sed -i '/libbfio\/Makefile/d' configure.ac
    sed -i '/libcdata/d' Makefile.am
    sed -i '/libcdata\/Makefile/d' configure.ac
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcfile/d' Makefile.am
    sed -i '/libcfile\/Makefile/d' configure.ac
    sed -i '/libclocale/d' Makefile.am
    sed -i '/libclocale\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
    sed -i '/libcpath/d' Makefile.am
    sed -i '/libcpath\/Makefile/d' configure.ac
    sed -i '/libcsplit/d' Makefile.am
    sed -i '/libcsplit\/Makefile/d' configure.ac
    sed -i '/libcthreads/d' Makefile.am
    sed -i '/libcthreads\/Makefile/d' configure.ac
    sed -i '/libfcache/d' Makefile.am
    sed -i '/libfcache\/Makefile/d' configure.ac
    sed -i '/libfdata/d' Makefile.am
    sed -i '/libfdata\/Makefile/d' configure.ac
    sed -i '/libfdatetime/d' Makefile.am
    sed -i '/libfdatetime\/Makefile/d' configure.ac
    sed -i '/libfwnt/d' Makefile.am
    sed -i '/libfwnt\/Makefile/d' configure.ac
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
    libbfio
    libcdata
    libcerror
    libcfile
    libclocale
    libcnotify
    libcpath
    libcsplit
    libcthreads
    libfcache
    libfdata
    libfdatetime
    libfwnt
    libuna
  ];

  meta = with lib; {
    description = "libyal's library to access the Windows SuperFetch database (AGDB) format, with the agdbinfo tool";
    homepage = "https://github.com/libyal/libagdb";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
