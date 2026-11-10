
{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
, libcnotify
, libcdatetime
}:

stdenv.mkDerivation rec {
  pname = "libuna";
  version = "20260602";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libuna";
    rev = version;
    hash = "sha256-MchJrrd3iCBdrEL86YFKuuwxcTMe48KIuPLAjW7mIp4=";
  };

  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
    sed -i '/libcdatetime/d' Makefile.am
    sed -i '/libcdatetime\/Makefile/d' configure.ac
    sed -i '/libclocale/d' Makefile.am
    sed -i '/libclocale\/Makefile/d' configure.ac
    sed -i '/libcfile/d' Makefile.am
    sed -i '/libcfile\/Makefile/d' configure.ac
    sed -i '/libcnotify/d' Makefile.am
    sed -i '/libcnotify\/Makefile/d' configure.ac
    sed -i '/unatools/d' Makefile.am
    sed -i '/unatools\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
    libcnotify
    libcdatetime
  ];

  meta = with lib; {
    description = "libyal's Unicode and ASCII conversion support";
    homepage = "https://github.com/libyal/libuna";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}
