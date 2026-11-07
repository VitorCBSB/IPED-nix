# IPED for Nix

Unofficial Nix packaging for [IPED](https://github.com/sepinf-inc/IPED), the open source digital forensic tool developed by the Brazilian Federal Police. IPED is not in nixpkgs, and its Linux support assumes a traditional FHS-style system, so this flake packages everything it needs: the IPED-patched Sleuthkit, the JDKs, the optional external tools, and a launcher that works around IPED's habit of keeping its configuration in its own install directory.

This repository is **not affiliated with or endorsed by the IPED project**. Report IPED bugs upstream and packaging problems here.

## Status

Developed and tested on NixOS (x86_64-linux) with IPED 4.3.1.

| Part | State |
|---|---|
| Processing evidence (`iped -d ... -o ...`) | Works |
| Analysis GUI (`iped-search <case-folder>`) | Opens and runs; the startup log shows only the SuperFetch message listed below |
| Optional external tools | All of IPED's startup self-checks pass except SuperFetch and DBX (see [Not covered yet](#not-covered-yet)) |
| Python modules (Jep) | Load without errors with Python 3.12, jep 4.0.3 and `beautifulsoup4`; other IPED Python tasks may need more packages |
| Parser output on real evidence | **Not yet validated.** Passing a startup self-check shows a tool runs, not that its output is correct |
| Viewer previews (HTML, Office, video) | Not yet verified |
| Other Linux distributions with Nix installed | **Untested**; expected to work with caveats, see [Using it on other distributions](#using-it-on-other-linux-distributions-ubuntu-etc) |
| aarch64, macOS | Not supported (the flake is `x86_64-linux` only) |

## What is in here

| File | Purpose |
|---|---|
| `flake.nix` | Wires everything together and defines the packages |
| `iped.nix` | Packages the official IPED release zip plus a launcher script. Takes `toolsBin` and `toolsLib` from `tools.nix` |
| `sleuthkit-iped.nix` | Builds the IPED-patched Sleuthkit fork with Java/JNI bindings |
| `liberica-jdk-full.nix` | Liberica OpenJDK 11 "Full" (bundles JavaFX), used by the GUI only |
| `tools.nix` | Optional external tools IPED looks for (OCR, libyal tools, Perl module, Python/Jep, ...) |
| `libyal.nix` | Small generic builder for libyal release tarballs, used by `tools.nix` for tools nixpkgs lacks |
| `libyal-versions.nix` | Pinned libyal release tarballs |
| `jep.nix` | Jep (Java Embedded Python) for IPED's Python modules |
| `rifiuti2.nix` | rifiuti2 (Windows Recycle Bin parsers), built from source |

Packages exposed by the flake: `iped` (processing), `iped-search` (analysis GUI), `sleuthkit-iped`, and `default` (`iped` + `iped-search` together).

## Usage

```sh
nix build github:<user>/<repo>                 # or: nix build . from a clone
./result/bin/iped --help
./result/bin/iped -d /path/to/evidence -o /path/to/output
./result/bin/iped-search /path/to/output       # open the processed case
```

The launcher does not change directory, so relative paths should resolve against your current directory. If IPED reports that it cannot find your evidence, try absolute paths (`-d "$(realpath ./evidence)"`); an older launcher that ran `cd` into the working copy resolved relative paths there.

Install into your user profile so the commands are on your `PATH`:

```sh
nix profile install github:<user>/<repo>
```

On NixOS you can instead add the flake as an input of your system configuration and put `inputs.iped.packages.${pkgs.stdenv.hostPlatform.system}.default` in `environment.systemPackages` (or `home.packages` with home-manager).

If you work from a clone, remember `git add` for new files, because flakes only see git-tracked files. On the first build, `lib.fakeHash` placeholders (if any are left) make Nix print the real hash; paste it in and rebuild.

Processing and viewing are separate programs. `iped` writes an output folder; `iped-search` opens it. A processed case is portable and carries its own copy of the viewer, so `iped-search` is only a launcher that provides a suitable JDK, libraries and tools. **Both commands need the same external tools on their `PATH`** (OCR, MPlayer, ImageMagick, ...); both get them from `tools.nix`.

## Using it on other Linux distributions (Ubuntu, etc.)

Nix runs on any Linux distribution, and everything this flake needs (JDKs, Sleuthkit, OCR, LibreOffice, the parsers) comes from the Nix store, so no `apt` packages are required. **This has not been tested outside NixOS**; the steps and caveats below follow from how Nix works.

### Steps (Ubuntu example)

1. Install Nix with the multi-user (daemon) installer, for example the Determinate installer (flakes enabled by default):

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

   or the official one: `sh <(curl -L https://nixos.org/nix/install) --daemon`. Check the respective project pages for the current commands. Open a new shell afterwards.

2. If you used the official installer, enable flakes:

   ```sh
   mkdir -p ~/.config/nix
   echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
   ```

3. Install:

   ```sh
   nix profile install github:<user>/<repo>
   ```

4. Make sure `~/.nix-profile/bin` is on your `PATH` (the installers normally arrange this), then run `iped` and `iped-search`.

The first build compiles Sleuthkit and several small libraries and downloads the Liberica JDK and the IPED release; LibreOffice and most other tools come from the public binary cache. Expect several GB of disk use (LibreOffice is the bulk).

### Caveats

- **Use the multi-user (daemon) install.** Recent Ubuntu releases restrict unprivileged user namespaces through AppArmor, which can break the Nix build sandbox in single-user installs. The daemon install is the default for both installers above.
- **Graphics acceleration.** Nix's OpenGL libraries cannot see your distribution's GPU drivers (the usual Nix-on-non-NixOS issue, which [nixGL](https://github.com/nix-community/nixGL) addresses). The JavaFX GUI should be able to fall back to software rendering; if the viewer crashes or draws nothing, try forcing it with `-Dprism.order=sw` in `JAVA_TOOL_OPTIONS`.
- **Fonts.** The Nix-provided fontconfig may not see your distribution's fonts. If the GUI fails with `Fontconfig head is null`, install a font through Nix (for example `nix profile install nixpkgs#dejavu_fonts`) or point `FONTCONFIG_FILE` at `/etc/fonts/fonts.conf`.
- **GTK dialogs.** File choosers and similar GTK dialogs can print GSettings/icon-theme warnings, because Nix's GTK does not use your system's data directories. These are usually harmless.
- **nixpkgs revision.** The flake tracks `nixos-unstable` and uses current attribute names (for example `libx11` instead of the deprecated `xorg.libX11`). Older nixpkgs revisions may need the old names.
- **Architecture.** `x86_64-linux` only.

Please open an issue with your distribution, Nix version and the exact error if you try this.

## How the launcher handles configuration

IPED keeps `conf/`, `profiles/`, `LocalConfig.txt` and more next to `iped.jar` and does not follow the XDG specification. `/nix/store` is read-only, so `iped` is a wrapper around a small launcher script that, on every start:

1. Copies the immutable release from the store to `${XDG_DATA_HOME:-~/.local/share}/iped/<version>/` if that directory does not exist yet (the writable working copy IPED runs from).
2. Copies the contents of `${XDG_CONFIG_HOME:-~/.config}/iped/` **over** the working copy, if that directory exists. Put overrides there, mirroring IPED's layout, e.g. `~/.config/iped/conf/ExternalParsers.xml`.
3. Rewrites `tskJarPath` in `LocalConfig.txt` to point at the Nix-built Sleuthkit jar.
4. Runs `java -jar iped.jar` with a `PATH` and `LD_LIBRARY_PATH` that include the required tools (set by the wrapper around the launcher).

Consequences worth knowing:

- Building the package does **not** create anything in your home directory. The working copy appears on first run.
- Files in `~/.config/iped/` always win. If an edit made directly in `~/.local/share/iped/<version>/` keeps disappearing, a copy in `~/.config/iped/` is overwriting it.
- Each IPED version gets its own working copy; delete old ones whenever you like.

## Why this is not a one-liner

1. **A custom Sleuthkit build is required.** On Linux IPED needs the `sepinf-inc/sleuthkit` fork (`4.15.0_iped_patch`) built with Java bindings, with the jar referenced from `LocalConfig.txt` (`tskJarPath`).
2. **That build wants the network.** Sleuthkit's Java build downloads dependency jars through Ivy. The Nix sandbox has no network, so `sleuthkit-iped.nix` pre-fetches every jar with `fetchurl`, builds with `--enable-offline`, and supplies an Ivy jar to Ant. The jar list and checksums come from the upstream 4.15.0 `ivy.xml`; **verify them against the fork's `bindings/java/ivy.xml` when bumping versions.**
3. **It needs an old libewf.** E01 support requires libewf 20140808 or older; current libewf dropped `libewf_handle_read_random`, so Sleuthkit fails to compile against it. nixpkgs ships the old version as `libewf-legacy`, which `sleuthkit-iped.nix` uses.
4. **It writes into its own root.** See the launcher section.
5. **It spawns a second JVM** using a plain `java` from `PATH`, so the right JDK must be on `PATH`, not just referenced by absolute path. Flags passed to the first JVM do not reach the second one.
6. **The GUI needs JavaFX**, and nixpkgs cannot provide a usable one for Java 11. See [Known issues](#known-issues).

## Optional tools

IPED degrades gracefully: when a tool is missing, the matching parser is disabled and an `[ERROR]` line is logged at startup. Those messages usually do **not** indicate a packaging bug. `tools.nix` supplies:

| Feature | Tool |
|---|---|
| OCR | Tesseract 5 with English, Portuguese and OSD data |
| Image formats | ImageMagick |
| Video thumbnails | MPlayer |
| Office document rendering | LibreOffice (`SAL_USE_VCLPLUGIN` is set in the wrapper) |
| Graph layout | graphviz |
| Recycle Bin | rifiuti2 (`rifiuti2.nix`) |
| Windows event logs, Prefetch, IE history, EDB / Edge | libyal tools: `libevtx`, `libevt`, `libscca`, `libmsiecf`, `libesedb`; `libpff` for Outlook OST |
| Registry reports | RegRipper (bundled) with Perl's `Parse::Win32Registry` |
| Python modules | Python 3.12 with `jep` (`jep.nix`) and `beautifulsoup4` on `PATH`, `libjep.so` on `LD_LIBRARY_PATH` |

`tools.nix` skips any package that cannot be provided and prints an evaluation warning such as `iped: no libscca (nixpkgs or libyal-versions.nix); run ./update-libyal.sh`. To see which libyal-related packages your nixpkgs has:

```sh
nix eval --impure --expr 'let p = (builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux; in builtins.listToAttrs (map (n: { name = n; value = builtins.hasAttr n p; }) [ "libesedb" "libpff" "libevtx" "libevt" "libscca" "libmsiecf" "rifiuti2" "libvmdk" "libvhdi" "libbfio" ])'
```

### libyal tools

For `libesedb`, `libevtx`, `libevt`, `libscca` and `libmsiecf`, `tools.nix` uses the nixpkgs package when there is one and otherwise builds the upstream release tarball with `libyal.nix`. libyal **deletes old release assets** from GitHub, so pinned versions go stale and start returning 404. `libyal-versions.nix` is therefore generated, not hand-written:

```sh
./update-libyal.sh > libyal-versions.nix
```

The script picks the newest release whose tarball can still be downloaded for each project and records its checksum. Re-run it whenever a libyal download fails.

### Recycle Bin (rifiuti2)

IPED looks for the commands `rifiuti2` and `rifiuti-vista`. The `rifiuti` package in nixpkgs did not satisfy IPED's checks, so `rifiuti2.nix` builds upstream rifiuti2 (CMake). Since version 0.8 its INFO2 tool installs as `rifiuti`, so the package adds a `rifiuti2` symlink.

### Python modules (Jep)

IPED's Python modules run through Jep. The native jep must match the jep jar shipped in IPED's `lib/` directory (`ls <release>/lib | grep -i jep`; IPED 4.3.1 ships `jep-4.0.3.jar`). `jep.nix` builds jep 4.0.3 against Python 3.12; it did not need changes beyond exporting `JAVA_HOME` through `env`. Python 3.11 also built jep, but current nixpkgs no longer supports parts of its package set (for example sphinx), which broke `beautifulsoup4`. IPED's Python tasks import further packages: when the log reports `No module named '...'`, add the package to `pythonModules` in `tools.nix`. The wrapper does not set `PYTHONPATH`; IPED appears to locate jep through the `python` on `PATH` (inferred from the fact that it works, not verified). To switch Jep off, pass `withJep = false` to `tools.nix` in `flake.nix`.

### Not covered yet

- **Windows SuperFetch** (`libagdb` / `agdbinfo`): libyal publishes no downloadable release tarball for it, so it is not packaged. IPED logs `Error testing SuperFetchParser` at every start; this is expected.
- **DBX (Outlook Express) mailboxes:** it is not known which external tool IPED's DBX parser expects, so it stays disabled.
- **Optional image formats in Sleuthkit** (VMDK, VHD, LVM): this needs `libvmdk`, `libvhdi`, `libvslvm` and `libbfio` and a Sleuthkit rebuild with the matching `--with-*` flags.
- **LibreOffice version:** IPED's wiki asks for LibreOffice 6; this flake uses whatever nixpkgs ships. No LibreOffice errors have been seen at startup, but document previews are not yet verified.

> **Forensic note:** a silently disabled parser means those artifact types are *absent* from your results, which is not the same as "none found". If you rely on IPED output in a report, record which parsers were active in that run (including the two above), and validate the tool in your own environment first.

## Known issues

- **JavaFX and the analysis GUI.** The GUI needs JavaFX. What did not work: `jdk11.override { enableJavaFX = true; }` is refused by nixpkgs, and nixpkgs `openjfx17` cannot be used on the module path (its modular SDK has no `module-info.class`, and it is built without WebKit). What works: the Liberica Full JDK 11, packaged in `liberica-jdk-full.nix`, which bundles JavaFX. It is a prebuilt binary patched with `autoPatchelfHook`.
- **Runtime libraries for the Liberica JDK.** The JDK `dlopen`s libraries such as fontconfig and GTK, and `autoPatchelfHook` does not wire up such libraries (`runtimeDependencies` did not help in our case). The `iped-search` script therefore sets `LD_LIBRARY_PATH` explicitly. Symptom if it is missing: a blank window and `Fontconfig head is null`.
- **Missing tools in `iped-search`.** An early `Error testing MPLAYER!` message went away once `iped-search` got the same tool `PATH` as `iped`. The most likely cause is that the search app simply had no MPlayer on its `PATH`; this was not confirmed. Keep the two commands' tool lists in sync (both use `tools.bin`).
- **`JAVA_TOOL_OPTIONS` quirk.** If you experiment with JVM flags through `JAVA_TOOL_OPTIONS`, long options must use the `--option=value` form.
- **Native libraries inside the Sleuthkit jar.** The jar bundles `libtsk_jni.so` and extracts it at runtime; the wrapper puts the Sleuthkit `lib/` directory on `LD_LIBRARY_PATH`. Look there first on `UnsatisfiedLinkError`.
- **Deprecation warnings are downgraded.** The IPED Sleuthkit fork uses OpenSSL 3 functions that are deprecated but functional, so the build uses `-Wno-error=deprecated-declarations`.
- **RPATH cleanup.** libtool leaves `/build/...` in the RPATH of installed `bin/*` programs, which Nix rejects, so `sleuthkit-iped.nix` rewrites them with `patchelf` in `preFixup`.
- **Pinned upstream downloads can disappear.** libyal removes old GitHub release assets, which is why `libyal-versions.nix` is generated. The same can happen to any pinned URL (for example the Liberica tarball or the IPED release); consider mirroring them if you need long-term reproducibility.

## Versions

| Component | Version |
|---|---|
| IPED | 4.3.1 (release zip with Java plugins; it has two top-level directories, hence `stripRoot = false`) |
| Sleuthkit fork | `sepinf-inc/sleuthkit` tag `4.15.0_iped_patch` |
| libewf | `libewf-legacy` from nixpkgs (20140808 or older) |
| JDK for processing | OpenJDK 11 |
| JDK for the GUI | Liberica Full 11.0.33.0.3+7 |
| Python / jep | Python 3.12 / jep 4.0.3 (must match IPED's jep jar) |
| rifiuti2 | 0.8.2 |
| libyal tools | newest downloadable release at generation time (see `libyal-versions.nix`) |

## Updating to a new IPED release

1. Bump `version` and the release URL in `iped.nix` and refresh the hash.
2. Read the new release notes for Java requirements and the recommended Sleuthkit fork tag; the IPED wiki's Linux page lists the required Sleuthkit patch level.
3. If the Sleuthkit tag changes, compare the fork's `bindings/java/ivy.xml` and `case-uco/java/ivy.xml` with the jar lists in `sleuthkit-iped.nix`.
4. Check whether the zip layout changed (`installPhase` in `iped.nix` depends on it).
5. Check the jep jar version in the new release's `lib/` and update `jep.nix` to match.
6. Re-run `./update-libyal.sh > libyal-versions.nix` if any libyal download fails.

## Contributing

Issues and pull requests are welcome, especially for testing on non-NixOS distributions, validating parser output against real evidence, and the tools that are still missing (SuperFetch, DBX). Please include your nixpkgs revision (or distribution and Nix version) and the exact error output.

## License

Copyright 2026 Vitor Coimbra

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

IPED, Sleuthkit, Liberica JDK and the other packaged tools have their own licenses, which apply to the software they provide; this repository contains only Nix packaging files.
