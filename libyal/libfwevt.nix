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
, libfdatetime
, libfguid
, libfwnt
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libfwevt";
  version = "20260702";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libfwevt";
    rev = version;
    hash = "sha256-K7gLPOd6hpffDtQQZR+/fyAp7XIHvZYO296B6zN/BZ4=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
  postPatch = ''
    sed -i '/libcdata/d' Makefile.am
    sed -i '/libcdata\/Makefile/d' configure.ac
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
    sed -i '/libcthreads/d' Makefile.am
    sed -i '/libcthreads\/Makefile/d' configure.ac
    sed -i '/libfdatetime/d' Makefile.am
    sed -i '/libfdatetime\/Makefile/d' configure.ac
    sed -i '/libfguid/d' Makefile.am
    sed -i '/libfguid\/Makefile/d' configure.ac
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
    libcdata
    libcerror
    libcnotify
    libcthreads
    libfdatetime
    libfguid
    libfwnt
    libuna
  ];

  meta = with lib; {
    description = "libyal's library for Windows Event Log data types";
    homepage = "https://github.com/libyal/libfwevt";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
