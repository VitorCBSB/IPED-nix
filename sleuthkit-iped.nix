{ lib, stdenv, fetchFromGitHub, fetchurl, autoreconfHook, pkg-config
, ant, jdk, openssl, zlib, libewf-legacy, sqlite
, libbfio ? null, libvmdk ? null, libvhdi ? null, libvslvm ? null, afflib ? null }:

let
  mvn = path: hash: fetchurl {
    url = "https://repo1.maven.org/maven2/${path}";
    inherit hash;
  };

  ivyJar = mvn "org/apache/ivy/ivy/2.5.0/ivy-2.5.0.jar" "sha256-L0yDW1IxHfki+KjrBXhD3lSFCIsjTM0D5Hi5Bmtea/w=";

  # bindings/java/ivy.xml (verify against the fork)
  javaDeps = [
    (mvn "joda-time/joda-time/2.13.1/joda-time-2.13.1.jar" "sha256-qb5HtGOQ96bausx8BVtP62+48iJUd6cnCoIzspbiZnc=")
    (mvn "com/google/guava/guava/33.4.0-jre/guava-33.4.0-jre.jar" "sha256-uRjJin5E2+lOvZ/j5Azdqttak+anjrYAi0LfI3JB5Tg=")
    (mvn "com/google/guava/failureaccess/1.0.2/failureaccess-1.0.2.jar" "sha256-io+Bz5s1nj9t+mkaHndphcBh7y8iPJssgHU+G0WOgGQ=")
    (mvn "org/apache/commons/commons-lang3/3.17.0/commons-lang3-3.17.0.jar" "sha256-bucx31yOWil2ocoCO2uzIOqNNTn75kyKHVy3ZRJ8M7Q=")
    (mvn "commons-validator/commons-validator/1.9.0/commons-validator-1.9.0.jar" "sha256-w8FHSOLXjbWN+IgIdAcRvWQ7MsRf+nuKc58A+0Z819c=")
    (mvn "com/google/code/gson/gson/2.12.1/gson-2.12.1.jar" "sha256-6+4T1ft0d81/HMAQ4MNW34yoBwlxUkjal/eeNcy0++w=")
    (mvn "junit/junit/4.13.2/junit-4.13.2.jar" "sha256-jklbY0Rp1k+4rPo0laBly6zIoP/1XOHjEAe+TBbcV9M=")
    (mvn "io/github/java-diff-utils/java-diff-utils/4.12/java-diff-utils-4.12.jar" "sha256-mZCiA5d49rTMlHkBQcKGiGTqzuBiDGxFlFESGpAc1bU=")
    (mvn "org/postgresql/postgresql/42.7.5/postgresql-42.7.5.jar" "sha256-aQILO9IJhFQ+gXOT8ubAGokO8uN6d90R1thQgYHQeas=")
    (mvn "com/mchange/c3p0/0.12.0/c3p0-0.12.0.jar" "sha256-TYWn1GQ6It9+niGhWeAi3kYlMHJ0Q+yD0ZAyHrMFhR0=")
    (mvn "com/mchange/mchange-commons-java/0.4.0/mchange-commons-java-0.4.0.jar" "sha256-/YjjhaON93ARd7B241BIqEHcXfERjGsthgu6CMQbwLY=")
    (mvn "com/zaxxer/SparseBitSet/1.3/SparseBitSet-1.3.jar" "sha256-92uFrbDAByGuJnt8/eTaf3HTEhzCFgyfwAwMifjFPIo=")
    # sqlite-jdbc (version from ivy.xml)
    (mvn "org/xerial/sqlite-jdbc/3.49.1.0/sqlite-jdbc-3.49.1.0.jar" "sha256-XIYJ0so0HeuMb3F3iXS1ukmVx9MtfHyJ2TkqPnLDkpE=")
  ];

  # case-uco/java/ivy.xml
  ucoDeps = [
    (mvn "com/google/code/gson/gson/2.8.5/gson-2.8.5.jar" "sha256-IzoBSfw2XJ9u29aDz+JmsZvcdzvpjqva9rPJJLSOfYE=")
    (mvn "junit/junit/4.12/junit-4.12.jar" "sha256-WXIfCAXiI9hLkGd4h9n/Vn3FNNfFAsqQPAwrF/BcEWo=")
    (mvn "org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar" "sha256-Zv3vkelzk0jfeglqo4SlaF9Oh1WEzOiThqekclHE2Ok=")
  ];

  copyJars = dir: jars:
    lib.concatMapStringsSep "\n" (j: "cp --no-preserve=mode ${j} ${dir}/${j.name}") jars;
in
stdenv.mkDerivation {
  pname = "sleuthkit-iped";
  version = "4.15.0-iped";

  src = fetchFromGitHub {
    owner = "sepinf-inc";
    repo = "sleuthkit";
    rev = "4.15.0_iped_patch";
    hash = "sha256-02dbsKhsPxP5OyXGrl8xO0YZ13cpg7kBC4g5dDfmd6Q=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ant jdk ];
  # libbfio, libvmdk, libvhdi, libvslvm and afflib add VMDK, VHD, LVM and AFF image
  # support. configure detects them automatically; check the "Features" summary in
  # the build log (nix log .#sleuthkit-iped) to see which were picked up.
  buildInputs =
    [ openssl zlib libewf-legacy sqlite ]
    ++ lib.filter (p: p != null) [ libbfio libvmdk libvhdi libvslvm afflib ];

  configureFlags = [ "--enable-java" "--enable-offline" ];
  JAVA_HOME = jdk.home;
  env = {
    NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";
  };

  preBuild = ''
    mkdir -p $NIX_BUILD_TOP/.ant/lib
    cp --no-preserve=mode ${ivyJar} "$NIX_BUILD_TOP/.ant/lib/"

    mkdir -p bindings/java/lib case-uco/java/lib
    ${copyJars "bindings/java/lib" javaDeps}
    ${copyJars "case-uco/java/lib" ucoDeps}
  '';

  postPatch = ''
    substituteInPlace bindings/java/build.xml --replace-fail 'location="/usr/share/java"' 'location="lib"'
  '';

  postInstall = ''
    mkdir -p $out/share/java
    cp bindings/java/dist/sleuthkit-*.jar $out/share/java/sleuthkit.jar
  '';

  preFixup = ''
    for f in $out/bin/*; do
      [ -f "$f" ] && [ ! -L "$f" ] || continue
      if rpath=$(patchelf --print-rpath "$f" 2>/dev/null) && [[ "$rpath" == *"$NIX_BUILD_TOP"* ]]; then
        new=$(echo "$rpath" | tr ':' '\n' | grep -v "^$NIX_BUILD_TOP" | paste -sd:)
        patchelf --set-rpath "$out/lib''${new:+:$new}" "$f"
      fi
    done
  '';
}
