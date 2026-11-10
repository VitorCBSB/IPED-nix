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
  pname = "libcthreads";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcthreads";
    rev = version;
    hash = "sha256-TJ/htMF+CYGIvGk5Wm3RbZIi0qHEcBhc/DNnWPWq6WI=";
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
    description = "libyal's cross platform C thread functions";
    homepage = "https://github.com/libyal/libcthreads";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}
