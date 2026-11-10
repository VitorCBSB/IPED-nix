# libyal libraries built from pinned git tags (see each file for its tag and hash).
#
# The git trees expect ./synclibs.sh to copy their dependencies in. Here every
# dependency is a package of its own, wired by name through this scope: a file
# that takes `libcerror` as an argument gets the libcerror defined below.
#
# NOTE: synclibs.sh's LOCAL_LIBS is not a reliable dependency list (libuna also
# needs libcnotify and libcdatetime). When adding a library, trust configure's
# errors.
{ lib, newScope }:

lib.makeScope newScope (self: {
  libcerror     = self.callPackage ./libcerror.nix { };
  libcthreads   = self.callPackage ./libcthreads.nix { };
  libcnotify    = self.callPackage ./libcnotify.nix { };
  libclocale    = self.callPackage ./libclocale.nix { };
  libcsplit     = self.callPackage ./libcsplit.nix { };
  libcdatetime  = self.callPackage ./libcdatetime.nix { };
  libfdatetime  = self.callPackage ./libfdatetime.nix { };
  libuna        = self.callPackage ./libuna.nix { };
  libcdata      = self.callPackage ./libcdata.nix { };
  libfcache     = self.callPackage ./libfcache.nix { };
  libfwnt       = self.callPackage ./libfwnt.nix { };
  libfdata      = self.callPackage ./libfdata.nix { };
  libcfile      = self.callPackage ./libcfile.nix { };
  libcpath      = self.callPackage ./libcpath.nix { };
  libbfio       = self.callPackage ./libbfio.nix { };
  libagdb       = self.callPackage ./libagdb.nix { };

  # Component libraries needed by the tools below. Add them one at a time and build
  # each (nix build .#<name>) before adding the next.
  libfguid      = self.callPackage ./libfguid.nix { };
  libfole       = self.callPackage ./libfole.nix { };
  libmapidb     = self.callPackage ./libmapidb.nix { };
  libcdirectory = self.callPackage ./libcdirectory.nix { };
  libfvalue     = self.callPackage ./libfvalue.nix { };
  libfwevt      = self.callPackage ./libfwevt.nix { };
  libfmapi      = self.callPackage ./libfmapi.nix { };
  libexe        = self.callPackage ./libexe.nix { };
  libregf       = self.callPackage ./libregf.nix { };
  libwrc        = self.callPackage ./libwrc.nix { };

  # Libraries that replace the release tarballs of libyal-versions.nix. An entry here
  # takes precedence over the tarball package of the same name; comment out entries that
  # do not build yet.
  libscca       = self.callPackage ./libscca.nix { };
  libmsiecf     = self.callPackage ./libmsiecf.nix { };
  libesedb      = self.callPackage ./libesedb.nix { };
  libvmdk       = self.callPackage ./libvmdk.nix { };
  libvhdi       = self.callPackage ./libvhdi.nix { };
  libvslvm      = self.callPackage ./libvslvm.nix { };
  libevt        = self.callPackage ./libevt.nix { };
  libevtx       = self.callPackage ./libevtx.nix { };
})
