{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libbfio
, libcdata
, libcdirectory
, libcerror
, libcfile
, libclocale
, libcnotify
, libcpath
, libcsplit
, libcthreads
, libexe
, libfcache
, libfdata
, libfdatetime
, libfguid
, libfvalue
, libfwevt
, libfwnt
, libregf
, libuna
, libwrc
}:

stdenv.mkDerivation rec {
  pname = "libevt";
  version = "20260705";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libevt";
    rev = version;
    hash = "sha256-AYm1RIPwwohX7iCn248bFHnMJgNQ+0DC3QXdKbBNgCE=";   # filled in by fill-libyal-pins.sh
  };

  # The git tree expects ./synclibs.sh to copy its dependencies in. They are
  # separate packages here, so drop the references to the bundled copies.
  postPatch = ''
    sed -i '/libbfio/d' Makefile.am
    sed -i '/libbfio\/Makefile/d' configure.ac
    sed -i '/libcdata/d' Makefile.am
    sed -i '/libcdata\/Makefile/d' configure.ac
    sed -i '/libcdirectory/d' Makefile.am
    sed -i '/libcdirectory\/Makefile/d' configure.ac
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
    sed -i '/libexe/d' Makefile.am
    sed -i '/libexe\/Makefile/d' configure.ac
    sed -i '/libfcache/d' Makefile.am
    sed -i '/libfcache\/Makefile/d' configure.ac
    sed -i '/libfdata/d' Makefile.am
    sed -i '/libfdata\/Makefile/d' configure.ac
    sed -i '/libfdatetime/d' Makefile.am
    sed -i '/libfdatetime\/Makefile/d' configure.ac
    sed -i '/libfguid/d' Makefile.am
    sed -i '/libfguid\/Makefile/d' configure.ac
    sed -i '/libfvalue/d' Makefile.am
    sed -i '/libfvalue\/Makefile/d' configure.ac
    sed -i '/libfwevt/d' Makefile.am
    sed -i '/libfwevt\/Makefile/d' configure.ac
    sed -i '/libfwnt/d' Makefile.am
    sed -i '/libfwnt\/Makefile/d' configure.ac
    sed -i '/libregf/d' Makefile.am
    sed -i '/libregf\/Makefile/d' configure.ac
    sed -i '/libuna/d' Makefile.am
    sed -i '/libuna\/Makefile/d' configure.ac
    sed -i '/libwrc/d' Makefile.am
    sed -i '/libwrc\/Makefile/d' configure.ac
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
    libcdirectory
    libcerror
    libcfile
    libclocale
    libcnotify
    libcpath
    libcsplit
    libcthreads
    libexe
    libfcache
    libfdata
    libfdatetime
    libfguid
    libfvalue
    libfwevt
    libfwnt
    libregf
    libuna
    libwrc
  ];

  meta = with lib; {
    description = "libyal's library to access the Windows Event Log (EVT) format, with evtexport";
    homepage = "https://github.com/libyal/libevt";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
