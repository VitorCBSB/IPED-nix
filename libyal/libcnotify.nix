{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
, libcerror
}:

stdenv.mkDerivation rec {
  pname = "libcnotify";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcnotify";
    rev = version;
    hash = "sha256-CnKKkzfMdBq9dBZ6qEPU/ptKws8/a14Iy1Ctu/l1t6Y=";
  };

  postPatch = ''
    sed -i '/libcerror/d' Makefile.am
    sed -i '/libcerror\/Makefile/d' configure.ac
  '';

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    libcerror
  ];

  meta = with lib; {
    description = "libyal's library for cross platform C notification functions";
    homepage = "https://github.com/libyal/libcnotify";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}

