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
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libexe";
  version = "20260705";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libexe";
    rev = version;
    hash = "sha256-s2S9R2ruBHQplfFY9w0clizhQaD8rTYr4hV4yrmbNDE=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
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
    libuna
  ];

  meta = with lib; {
    description = "libyal's library to access the executable (EXE) format";
    homepage = "https://github.com/libyal/libexe";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
