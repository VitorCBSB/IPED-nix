# IPED for Nix

Unofficial Nix packaging for [IPED](https://github.com/sepinf-inc/IPED), the open source digital forensic tool developed by the Brazilian Federal Police. IPED is not in nixpkgs, and its Linux support assumes a traditional FHS-style system, so this flake packages everything it needs: the IPED-patched Sleuthkit, the JDKs, the optional external tools, and a launcher that works around IPED's habit of keeping its configuration in its own install directory.

This repository is **not affiliated with or endorsed by the IPED project**. Report IPED bugs upstream and packaging problems here.

## Status

Developed and tested on NixOS (x86_64-linux) with IPED 4.3.1.

| Part | State |
|---|---|
| Processing evidence (`iped -d ... -o ...`) | Works |
| Analysis GUI (`iped-search <case-folder>`) | Opens and runs |
| Optional external tools and plugins | IPED's startup log shows no missing-tool errors (SuperFetch and DBX included). The output of the Windows-artifact parsers has not been checked against real evidence |
| Disk image formats | E01 (via `libewf-legacy`) plus VMDK, VHD, LVM and AFF (Sleuthkit is built with libbfio, libvmdk, libvhdi, libvslvm and afflib). The build works; none of these formats has been tested with a real image |
| Python modules (Jep) | Load without errors with Python 3.12, jep 4.0.3 and `beautifulsoup4`; other IPED Python tasks may need more packages |
| Audio transcription: Vosk (IPED's default) | Works. Tested with one minute of Portuguese speech in an `.ogg` file; `language = pt-BR` had to be set because the test machine's locale was English |
| Audio transcription: Whisper (local, CPU) | Works (faster-whisper; the model is downloaded on first use). **Enabled by default in this flake, which makes builds much slower**; see [Audio transcription](#audio-transcription) |
| Audio transcription: Whisper on an NVIDIA GPU | Works with `withWhisperGpu = true` (off by default). Tested on one machine: GeForce RTX 3050, driver 615.78.08; see [GPU](#gpu-nvidia) |
| Audio transcription: Wav2Vec2 (local), Remote | Wav2Vec2 is not packaged; the Remote client has not been tested |
| Real-world test | The author processed a 10 GB folder of real files (PDF, JPEG, JPG, MP3, M4A, DOC, DOCX, OGG and others) and everything worked. **Not yet tried on real data:** the Windows-artifact parsers (event logs, Prefetch, SuperFetch, registry, Recycle Bin, IE/Edge history), disk images (E01, VMDK, VHD, LVM, AFF), `.dbx` mailboxes and Telegram databases. This is one person's test, not a systematic validation of parser output |
| Viewer previews | Checked by the author for the file types of the real-world test (PDF, JPEG, JPG, MP3, M4A, DOC, DOCX, OGG): they worked. HTML and video previews have not been checked specifically |
| Other Linux distributions with Nix installed | **Untested**; expected to work with caveats, see [Using it on other distributions](#using-it-on-other-linux-distributions-ubuntu-etc) |
| aarch64, macOS | Not supported (the flake is `x86_64-linux` only) |

## What is in here

| File | Purpose |
|---|---|
| `flake.nix` | Wires everything together and defines the packages |
| `iped.nix` | Packages the official IPED release zip (including its optional plugin jars) plus a launcher script. Takes `toolsBin` and `toolsLib` from `tools.nix` |
| `sleuthkit-iped.nix` | Builds the IPED-patched Sleuthkit fork with Java/JNI bindings |
| `liberica-jdk-full.nix` | Liberica OpenJDK 11 "Full" (bundles JavaFX), used by the GUI only |
| `tools.nix` | Optional external tools IPED looks for (OCR, libyal tools, Perl module, Python with Jep and Whisper, ...) |
| `libyal/` | The libyal libraries and tools (libesedb, libevtx, libevt, libscca, libmsiecf, libagdb, libvmdk, libvhdi, libvslvm and everything they depend on), each built from a git tag pinned by hash. |
| `jep.nix` | Jep (Java Embedded Python) for IPED's Python modules |
| `rifiuti2.nix` | rifiuti2 (Windows Recycle Bin parsers), built from source |

Packages exposed by the flake: `iped` (processing), `iped-search` (analysis GUI), `sleuthkit-iped`, and `default` (`iped` + `iped-search` together).

## Usage

```sh
nix build github:VitorCBSB/IPED-nix            # or: nix build . from a clone
./result/bin/iped --help
./result/bin/iped -d /path/to/evidence -o /path/to/output
./result/bin/iped-search /path/to/output       # open the processed case
```

The launcher does not change directory, so relative paths should resolve against your current directory. If IPED reports that it cannot find your evidence, try absolute paths (`-d "$(realpath ./evidence)"`); an older launcher that ran `cd` into the working copy resolved relative paths there.

Install into your user profile so the commands are on your `PATH`:

```sh
nix profile install github:VitorCBSB/IPED-nix
```

On NixOS you can instead add the flake as an input of your system configuration and put `inputs.iped.packages.${pkgs.stdenv.hostPlatform.system}.default` in `environment.systemPackages` (or `home.packages` with home-manager).

If you work from a clone, remember `git add` for new files, because flakes only see git-tracked files. On the first build, `lib.fakeHash` placeholders (if any are left) make Nix print the real hash; paste it in and rebuild.

**Build time:** with local Whisper transcription enabled (the default in `flake.nix`), the build pulls in large machine-learning dependencies and takes much longer than without it. If you do not need Whisper, set `withWhisper = false` in `flake.nix` (see [Audio transcription](#audio-transcription)).

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
   nix profile install github:VitorCBSB/IPED-nix
   ```

4. Make sure `~/.nix-profile/bin` is on your `PATH` (the installers normally arrange this), then run `iped` and `iped-search`.

The first build compiles Sleuthkit and several small libraries and downloads the Liberica JDK and the IPED release; LibreOffice and most other tools come from the public binary cache. Expect several GB of disk use (LibreOffice is the bulk). With Whisper enabled (the default) the build also needs the machine-learning libraries described under [Audio transcription](#audio-transcription), which takes much longer and needs more disk space.

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

1. Copies the immutable release from the store to `${XDG_DATA_HOME:-~/.local/share}/iped/<version>/` (the writable working copy IPED runs from) if that directory does not exist yet or if the package has changed. A stamp file in the working copy records the store path of the release that was copied.
2. Copies the contents of `${XDG_CONFIG_HOME:-~/.config}/iped/` **over** the working copy, if that directory exists. Put overrides there, mirroring IPED's layout, e.g. `~/.config/iped/conf/ExternalParsers.xml`.
3. Rewrites `LocalConfig.txt`: it adds the final newline that the release's file lacks, points `tskJarPath` at the Nix-built Sleuthkit jar, and sets `pluginFolder = plugins` (see [Plugins](#plugins-dbx-telegram-named-entity-recognition)).
4. Runs `mplayer` once if it has no configuration directory yet (`~/.mplayer` or `$XDG_CONFIG_HOME/mplayer`). MPlayer creates that directory on its first run, and IPED's own MPlayer self-test fails with `Error testing MPLAYER!` until it exists, which happens on a fresh home directory.
5. Runs `java -jar iped.jar` with a `PATH` and `LD_LIBRARY_PATH` that include the required tools (set by the wrapper around the launcher).

Consequences worth knowing:

- Building the package does **not** create anything in your home directory. The working copy appears on first run.
- Files in `~/.config/iped/` always win. If an edit made directly in `~/.local/share/iped/<version>/` keeps disappearing, a copy in `~/.config/iped/` is overwriting it.
- Each IPED version gets its own working copy; delete old ones whenever you like.
- When the package changes (a new store path), the release is copied over the working copy again, so edits made directly in the working copy are lost. Keep persistent changes in `~/.config/iped/`.
- The release's `LocalConfig.txt` does not end with a newline. An earlier launcher appended its `tskJarPath` line directly, which glued it onto the last line (`pluginFolder = ../plugins/tskJarPath = ...`). That made the first run of a fresh working copy fail with `You must set tskJarPath on LocalConfig.txt!` and left the plugin folder path invalid.

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
| Windows event logs, Prefetch, SuperFetch, IE history, EDB / Edge | libyal tools: `libevtx`, `libevt`, `libscca`, `libagdb`, `libmsiecf`, `libesedb`; `libpff` for Outlook OST |
| Registry reports | RegRipper (bundled) with Perl's `Parse::Win32Registry` |
| Python modules | Python 3.12 with `jep` (`jep.nix`) and `beautifulsoup4` (plus `faster-whisper` and `gputil` with `withWhisper`) on `PATH`, `libjep.so` on `LD_LIBRARY_PATH` |
| Audio transcription (Vosk) | libstdc++ on `LD_LIBRARY_PATH`, MPlayer for audio conversion |
| Optional IPED plugins | DBX decoder, Telegram decoder and Stanford CoreNLP jars from the release's `plugins/` directory |

`tools.nix` skips any package that cannot be provided and prints an evaluation warning such as `iped: no libscca in libyal/ or nixpkgs; the parser that needs it stays disabled`.

### libyal libraries and tools (`libyal/`)

IPED's artifact parsers call command-line tools from the libyal projects: `esedbexport` (libesedb), `evtxexport` (libevtx), `evtexport` (libevt), `sccainfo` (libscca), `msiecfexport` (libmsiecf) and `agdbinfo` (libagdb, for SuperFetch). `pffexport` (libpff) comes from nixpkgs. Sleuthkit also uses libyal's libbfio, libvmdk, libvhdi and libvslvm for VMDK, VHD and LVM images.

libyal publishes release tarballs for only some of its projects and deletes old ones, and its git trees expect `./synclibs.sh` to download their dependencies at build time (the latest tag of each). That is neither possible in the Nix sandbox nor reproducible. So `libyal/` packages each of these libraries and all of their libyal dependencies (34 packages) separately, every one built from a git tag pinned by hash, and `libyal/default.nix` wires them together by name. Nothing depends on a libyal release tarball or on a download at build time.

Notes for adding or updating a library:

- Each package deletes the references to the bundled copies of its dependencies from `Makefile.am` and `configure.ac`, because the separate packages replace them.
- `synclibs.sh`'s `LOCAL_LIBS` is not a reliable dependency list: libuna also needs libcnotify and libcdatetime although it lists only libcerror. Trust the errors from `configure`.
- libuna's command-line tools (`unatools`) are removed, because they need libcfile, which itself needs libuna.
- libfuse is not provided, so the mount tools (`vmdkmount` and similar) are skipped. IPED does not use them.
- `libyal/libyal-closure.py` maps the dependency closure of libraries from `synclibs.sh` and `configure.ac`, and `libyal/fill-libyal-pins.sh` sets the newest date tag and hash in a package file.

### Recycle Bin (rifiuti2)

IPED looks for the commands `rifiuti2` and `rifiuti-vista`. The `rifiuti` package in nixpkgs did not satisfy IPED's checks, so `rifiuti2.nix` builds upstream rifiuti2 (CMake). Since version 0.8 its INFO2 tool installs as `rifiuti`, so the package adds a `rifiuti2` symlink.

### Python modules (Jep)

IPED's Python modules run through Jep. The native jep must match the jep jar shipped in IPED's `lib/` directory (`ls <release>/lib | grep -i jep`; IPED 4.3.1 ships `jep-4.0.3.jar`). `jep.nix` builds jep 4.0.3 against Python 3.12; it did not need changes beyond exporting `JAVA_HOME` through `env`. Python 3.11 also built jep, but current nixpkgs no longer supports parts of its package set (for example sphinx), which broke `beautifulsoup4`. IPED's Python tasks import further packages: when the log reports `No module named '...'`, add the package to `pythonModules` in `tools.nix`. The wrapper does not set `PYTHONPATH`; IPED appears to locate jep through the `python` on `PATH` (inferred from the fact that it works, not verified). To switch Jep off, pass `withJep = false` to `tools.nix` in `flake.nix`.

### Plugins (DBX, Telegram, named-entity recognition)

The IPED release zip has a second top-level directory, `plugins/`, with optional jars whose licenses (GPL) rule out bundling them in IPED itself:

- `java-dbx-1.1-p6.jar` decodes Outlook Express DBX mailboxes. IPED's `OutlookDBXParser` loads its implementation class by name and logs `DBX parser not found` if that fails, so no external tool is involved.
- `telegram-decoder-impl-1.0.14.jar` is the implementation behind the Telegram parser.
- `stanford-corenlp-3.8.0.jar` enables named-entity recognition; its models must be downloaded separately.

`iped.nix` installs them into the `plugins/` folder inside IPED's root, and the launcher sets `pluginFolder = plugins` in `LocalConfig.txt` (IPED's default is `../plugins/`, relative to its root). The jars are fetched from the official release at build time; this repository does not redistribute them. After the fix, the `DBX parser not found` message disappeared; DBX parsing itself has not been tried with a real `.dbx` file, and neither has the Telegram decoder.

### Not covered yet

- **LibreOffice version:** IPED's wiki asks for LibreOffice 6; this flake uses whatever nixpkgs ships. No LibreOffice errors have been seen at startup, and DOC and DOCX previews worked in the author's test.
- **Wav2Vec2 and GPU transcription, Remote server nodes:** see [Audio transcription](#audio-transcription).

> **Forensic note:** a silently disabled parser means those artifact types are *absent* from your results, which is not the same as "none found". If you rely on IPED output in a report, record which parsers were active in that run, and validate the tool in your own environment first.

## Audio transcription

IPED has several audio transcription backends, selected in `conf/AudioTranscriptConfig.txt`. Status with this packaging:

| Backend | Status |
|---|---|
| **Vosk** (IPED's default) | Works. Tested once, with about a minute of Portuguese speech in an `.ogg` file. The small English and Portuguese models ship in the IPED release, and audio is converted with MPlayer. `tools.nix` also puts libstdc++ on `LD_LIBRARY_PATH` for Vosk's prebuilt native library (a precaution; it was not tested without it). |
| **Whisper** (local, faster-whisper) | Works on CPU. Enabled by `withWhisper = true`, which is the default in `flake.nix` and adds `faster-whisper` and `gputil` to the Python environment. In the author's test the result was clearly more accurate than Vosk (an impression from one test, not a benchmark). |
| **Wav2Vec2** (local) | **Not packaged.** It needs the `huggingsound` Python library and a PyTorch stack. |
| **Remote** | The client side needs no extra packages, only configuration (below). It has **not been tested** here. The service side (discovery and transcription nodes) is not packaged. |
| Azure, Google | Not covered (they need extra jars and credentials). |
| GPU transcription (Whisper) | Works on NVIDIA GPUs with `withWhisperGpu = true` in `flake.nix` (off by default). It builds CTranslate2 with CUDA; the CUDA libraries are unfree and not in the public binary cache, so this compiles locally and is slow. Tested on one machine only; see [GPU](#gpu-nvidia). GPU for Wav2Vec2 would need a CUDA build of PyTorch and is not covered. |

### Build cost of Whisper

Whisper's Python dependencies include large machine-learning libraries (the build output showed PyTorch, among others). On the author's machine, enabling `withWhisper` made a clean build more than 30 times slower than before (about 3 minutes without it). If you do not need local Whisper, set `withWhisper = false` in `flake.nix` to get the fast build back. `withWhisperGpu = true` adds a local compile of CTranslate2 with CUDA on top of that.

### GPU (NVIDIA)

There is no fundamental obstacle to running Whisper on a GPU under Nix, but the pieces are not built that way by default. faster-whisper runs on CTranslate2, which nixpkgs builds CPU-only; GPU use needs it rebuilt with CUDA and cuDNN. Those libraries are unfree, so you need `allowUnfree`, and because the public binary cache has no binaries for them, CTranslate2 compiles on your machine.

`withWhisperGpu = true` in `flake.nix` does the following:

- allows unfree packages and restricts CUDA code to compute capability 8.6 (Ampere, for example the RTX 3050). Remove or edit `cudaCapabilities` if your machines have other GPUs; the build will then take longer.
- rebuilds CTranslate2 and faster-whisper with CUDA and cuDNN (`tools.nix`).
- puts `/run/opengl-driver/lib`, where NixOS exposes the NVIDIA driver libraries, on `LD_LIBRARY_PATH` for the wrappers.

Then select the GPU in your `AudioTranscriptConfig.txt` overlay:

```
implementationClass = iped.engine.task.transcript.WhisperTranscriptTask
device = gpu
precision = float16
```

You need a working NVIDIA driver, new enough for the CUDA version nixpkgs uses. Mind the card's memory: larger Whisper models need more VRAM, and `int8` precision reduces memory use. This was tested on one machine, a GeForce RTX 3050 with driver 615.78.08, using the CUDA 13.x toolchain and CTranslate2 4.8.4 from the nixpkgs revision pinned in `flake.lock`. The override arguments in `tools.nix` have changed between nixpkgs versions, so a different revision may need adjustments, and other GPU generations need a different `cudaCapabilities` setting. To see whether the GPU is actually used, watch `nvidia-smi` while a case is being processed.

### Enabling it

1. Enable the module in `conf/IPEDConfig.txt`. Find the option name in your version with `grep -rn -i transcri ~/.local/share/iped/<version> --include=IPEDConfig.txt`.
2. Copy `AudioTranscriptConfig.txt` from the working copy to `~/.config/iped/conf/` and edit it there (the launcher re-applies it on every start).

Vosk:

```
implementationClass = iped.engine.task.transcript.VoskTranscriptTask
language = pt-BR
```

Whisper (CPU):

```
implementationClass = iped.engine.task.transcript.WhisperTranscriptTask
whisperModel = medium
device = cpu
precision = int8
```

Remote (client side):

```
implementationClass = iped.engine.task.transcript.RemoteTranscriptionTask
remoteServiceAddress = <ip>:<port>
```

The IPED wiki still describes an older remote setup (`RemoteWav2Vec2TranscriptTask` and a `wav2vec2Service` parameter); follow the `AudioTranscriptConfig.txt` that ships with your IPED version.

Notes:

- Transcription happens during processing, so a case processed before enabling it has to be processed again (into a new output folder).
- `language = auto` follows the `locale` set in `LocalConfig.txt`. If that is not your audio's language, set `language` explicitly (for example `pt-BR`). With Vosk this matters: it picks the model by language, and the test machine's English locale had to be overridden for Portuguese audio.
- Whisper models are downloaded from Hugging Face on first use. In the author's test this showed up as heavy network use with no log lines. Offline machines need a pre-populated Hugging Face cache (by default under `~/.cache/huggingface`).
- mp3 files are not transcribed by default. Add `audio/mpeg` to `mimesToProcess` to include them.
- Transcriptions are stored in the `audio:transcription` property, with a confidence score in `audio:transcriptConfidence`.

> **Forensic note:** automatic transcriptions can be wrong, and different backends give different results for the same audio. Treat them as leads, not as evidence, and check them against the recording.

## Known issues

- **JavaFX and the analysis GUI.** The GUI needs JavaFX. What did not work: `jdk11.override { enableJavaFX = true; }` is refused by nixpkgs, and nixpkgs `openjfx17` cannot be used on the module path (its modular SDK has no `module-info.class`, and it is built without WebKit). What works: the Liberica Full JDK 11, packaged in `liberica-jdk-full.nix`, which bundles JavaFX. It is a prebuilt binary patched with `autoPatchelfHook`.
- **Runtime libraries for the Liberica JDK.** The JDK `dlopen`s libraries such as fontconfig and GTK, and `autoPatchelfHook` does not wire up such libraries (`runtimeDependencies` did not help in our case). The `iped-search` script therefore sets `LD_LIBRARY_PATH` explicitly. Symptom if it is missing: a blank window and `Fontconfig head is null`.
- **`Error testing MPLAYER!`.** This message has appeared for two reasons. First, MPlayer had never run for that user, so its configuration directory did not exist yet (seen with a fresh home directory); both `iped` and `iped-search` now run `mplayer` once to create it. Second, an early version of `iped-search` may simply have lacked MPlayer on its `PATH` (not confirmed). Keep the two commands' tool lists in sync: both use `tools.bin`.
- **WhatsApp parser messages in the search app.** After processing a case, `iped-search` printed `WhatsAppParser: HashTask is disabled` and `SHA-256 is disabled`, saying the parser needs them to link attachments to chats. They are not caused by a missing external tool. IPED's manual says SHA-256 must be enabled for WhatsApp attachments to be linked to their conversations. It has not been investigated whether these messages only come from the viewer or reflect the processing configuration, so check your hash settings before processing WhatsApp evidence.
- **`JAVA_TOOL_OPTIONS` quirk.** If you experiment with JVM flags through `JAVA_TOOL_OPTIONS`, long options must use the `--option=value` form.
- **Native libraries inside the Sleuthkit jar.** The jar bundles `libtsk_jni.so` and extracts it at runtime; the wrapper puts the Sleuthkit `lib/` directory on `LD_LIBRARY_PATH`. Look there first on `UnsatisfiedLinkError`.
- **Deprecation warnings are downgraded.** The IPED Sleuthkit fork uses OpenSSL 3 functions that are deprecated but functional, so the build uses `-Wno-error=deprecated-declarations`.
- **RPATH cleanup.** libtool leaves `/build/...` in the RPATH of installed `bin/*` programs, which Nix rejects, so `sleuthkit-iped.nix` rewrites them with `patchelf` in `preFixup`.
- **Pinned upstream downloads can disappear.** libyal's deletion of old release assets broke an earlier version of this packaging, which is why the libyal libraries are now built from git tags. The Liberica tarball, the IPED release and the Maven jars used for Sleuthkit are still fetched from third-party URLs, and a git tag can in principle be moved or deleted too. Consider mirroring them if you need long-term reproducibility.
- **HTTP 504 while building the CUDA packages.** With `withWhisperGpu`, a build failed once because a patch download for the CUDA C++ headers package (`fix-make_tma_descriptor`) timed out on the host side with HTTP 504, which also failed everything that depends on it. Retrying later fixed it. Nix keeps whatever it already built, so a retry only repeats the failed fetch.

## Versions

| Component | Version |
|---|---|
| IPED | 4.3.1 (release zip with Java plugins; it has two top-level directories, hence `stripRoot = false`) |
| Sleuthkit fork | `sepinf-inc/sleuthkit` tag `4.15.0_iped_patch` |
| libewf | `libewf-legacy` from nixpkgs (20140808 or older) |
| JDK for processing | OpenJDK 11 |
| JDK for the GUI | Liberica Full 11.0.33.0.3+7 |
| Python / jep | Python 3.12 / jep 4.0.3 (must match IPED's jep jar) |
| faster-whisper, gputil | whatever the pinned nixpkgs provides (see `flake.lock`) |
| CUDA / CTranslate2 (`withWhisperGpu`) | CUDA 13.x and CTranslate2 4.8.4 from the pinned nixpkgs (see `flake.lock`) |
| rifiuti2 | 0.8.2 |
| libyal libraries and tools | the git tags pinned in `libyal/` |

## Updating to a new IPED release

1. Bump `version` and the release URL in `iped.nix` and refresh the hash.
2. Read the new release notes for Java requirements and the recommended Sleuthkit fork tag; the IPED wiki's Linux page lists the required Sleuthkit patch level.
3. If the Sleuthkit tag changes, compare the fork's `bindings/java/ivy.xml` and `case-uco/java/ivy.xml` with the jar lists in `sleuthkit-iped.nix`.
4. Check whether the zip layout changed (`installPhase` in `iped.nix` depends on it).
5. Check the jep jar version in the new release's `lib/` and update `jep.nix` to match.
6. To update a libyal library, run `libyal/fill-libyal-pins.sh <name>` (newest date tag and hash) in that directory, and rebuild.

## Contributing

Issues and pull requests are welcome, especially for testing on non-NixOS distributions, validating the Windows-artifact parsers and disk-image formats against real evidence, and the tools that are still missing (Wav2Vec2). Changes to the launcher should be tested with a fresh working copy (delete `~/.local/share/iped/<version>/`) and then a second run, since the first run once behaved differently from the second. Please include your nixpkgs revision (or distribution and Nix version) and the exact error output.

## License

Copyright 2026 Vitor Coimbra

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

IPED, Sleuthkit, Liberica JDK and the other packaged tools have their own licenses, which apply to the software they provide; this repository contains only Nix packaging files.
