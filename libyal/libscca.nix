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
, libfvalue
, libfwnt
, libuna
}:

stdenv.mkDerivation rec {
  pname = "libscca";
  version = "20260527";   # filled in by fill-libyal-pins.sh

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libscca";
    rev = version;
    hash = "sha256-d0quXPdk7Q0/uoE6gxBa28j9V9o/9yYtaiRinrD7gK4=";   # filled in by fill-libyal-pins.sh
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
    sed -i '/libfvalue/d' Makefile.am
    sed -i '/libfvalue\/Makefile/d' configure.ac
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
    libfvalue
    libfwnt
    libuna
  ];

  meta = with lib; {
    description = "libyal's library to access the Windows Prefetch File (SCCA) format, with sccainfo";
    homepage = "https://github.com/libyal/libscca";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
