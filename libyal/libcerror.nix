{ lib
, stdenv
, fetchFromGitHub
, autoconf
, automake
, autoreconfHook
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "libcerror";
  version = "20260703";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcerror";
    rev = version;
    hash = "sha256-sRpV4kQFnsokPd8OeFR5PoQthE1+HID92J0WFM5JwA0=";
  };

  nativeBuildInputs = [
    autoconf
    autoreconfHook
    automake
    pkg-config
  ];

  meta = with lib; {
    description = "libyal's cross platform C error functions";
    homepage = "https://github.com/libyal/libcerror";
    license = licenses.lgpl3Plus;
    platform = platforms.linux;
  };
}
