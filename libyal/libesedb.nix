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
, libfguid
, libfmapi
, libfvalue
, libfwnt
, libmapidb
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libesedb";
  version = "20260704";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libesedb";
    rev = version;
    hash = "sha256-TTDVXT+c/l1CU2UWWppA/OPu8YxP4AgqItCW0/FtFPU=";   # filled in by fill-libyal-pins.sh
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
    sed -i '/libfguid/d' Makefile.am
    sed -i '/libfguid\/Makefile/d' configure.ac
    sed -i '/libfmapi/d' Makefile.am
    sed -i '/libfmapi\/Makefile/d' configure.ac
    sed -i '/libfvalue/d' Makefile.am
    sed -i '/libfvalue\/Makefile/d' configure.ac
    sed -i '/libfwnt/d' Makefile.am
    sed -i '/libfwnt\/Makefile/d' configure.ac
    sed -i '/libmapidb/d' Makefile.am
    sed -i '/libmapidb\/Makefile/d' configure.ac
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
    libfguid
    libfmapi
    libfvalue
    libfwnt
    libmapidb
    libuna
  ];

  meta = with lib; {
    description = "libyal's library to access the Extensible Storage Engine (ESE) database (EDB) format, with esedbexport";
    homepage = "https://github.com/libyal/libesedb";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
