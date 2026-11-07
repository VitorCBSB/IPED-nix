# Jep (Java Embedded Python), used by IPED's Python modules.
#
# The version MUST match the jep jar shipped in IPED's lib/ directory:
#   ls <iped-release>/lib | grep -i jep        (IPED 4.3.1 ships jep-4.0.3.jar)
{ lib, buildPythonPackage, fetchPypi, jdk }:

buildPythonPackage rec {
  pname = "jep";
  version = "4.0.3";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-r5A7BDbSSCTLs2Tp3EnV3kv5j04ZiZdV78ux0hUUBuQ=";
  };

  nativeBuildInputs = [ jdk ];
  # With structuredAttrs, plain attributes are not exported as environment
  # variables, so JAVA_HOME has to go through `env`.
  env.JAVA_HOME = jdk.home;

  doCheck = false;
  # jep can only be imported from inside a JVM
  pythonImportsCheck = [ ];

  meta = {
    description = "Java Embedded Python";
    homepage = "https://github.com/ninia/jep";
    license = lib.licenses.zlib;
  };
}
