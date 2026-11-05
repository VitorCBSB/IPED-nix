# Generic builder for libyal projects (https://github.com/libyal), built from
# their upstream release tarballs. Used by tools.nix for the libraries and
# command-line tools that nixpkgs does not package (libesedb, libevtx, ...).
#
# The release tarballs ship a generated configure script and bundled copies
# of the other libyal libraries they depend on, so no autoreconf and no
# network access are needed.
#
# Usage (see tools.nix):
#   mkLibyal { name = "libscca"; status = "alpha"; version = "20240427"; sha256 = "..."; }
#
# The tarball is expected at:
#   https://github.com/libyal/<name>/releases/download/<version>/<name>-<status>-<version>.tar.gz
# where <status> is the project's maturity label ("alpha", "experimental", ...).
{ lib, stdenv, fetchurl, pkg-config, zlib }:

{ name, status, version, sha256 ? null, hash ? null }:

stdenv.mkDerivation {
  pname = name;
  inherit version;

  src = fetchurl ({
    url = "https://github.com/libyal/${name}/releases/download/${version}/${name}-${status}-${version}.tar.gz";
  }
  // lib.optionalAttrs (hash != null) { inherit hash; }
  // lib.optionalAttrs (sha256 != null) { inherit sha256; });

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib ];

  meta = {
    homepage = "https://github.com/libyal/${name}";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
}
