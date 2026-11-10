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
, libfdatetime
, libfguid
, libfole
, libfvalue
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libmsiecf";
  version = "20260525";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libmsiecf";
    rev = version;
    hash = "sha256-lw2LKXd4m4T1+LfCfSYXhm0xwlw8Cbtitrrs9+5byHk=";   # filled in by fill-libyal-pins.sh
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
    sed -i '/libfdatetime/d' Makefile.am
    sed -i '/libfdatetime\/Makefile/d' configure.ac
    sed -i '/libfguid/d' Makefile.am
    sed -i '/libfguid\/Makefile/d' configure.ac
    sed -i '/libfole/d' Makefile.am
    sed -i '/libfole\/Makefile/d' configure.ac
    sed -i '/libfvalue/d' Makefile.am
    sed -i '/libfvalue\/Makefile/d' configure.ac
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
    libfdatetime
    libfguid
    libfole
    libfvalue
    libuna
  ];

  meta = with lib; {
    description = "libyal's library to access the Microsoft Internet Explorer cache file (index.dat) format, with msiecfexport";
    homepage = "https://github.com/libyal/libmsiecf";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
