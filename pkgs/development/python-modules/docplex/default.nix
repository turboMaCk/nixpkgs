{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy27,
  setuptools,
  futures ? null,
  docloud,
  requests,
}:

buildPythonPackage rec {
  pname = "docplex";
  version = "2.29.241";
  pyproject = true;

  # No source available from official repo
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rVJQOWvgzqArcycQeVu540XZkju7C/ZlIPZuuPHpiK0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools~=68.2.2" "setuptools>=68.2.2"
  '';

  build-system = [ setuptools ];

  propagatedBuildInputs = [
    docloud
    requests
  ] ++ lib.optional isPy27 futures;

  doCheck = false;
  pythonImportsCheck = [ "docplex" ];

  meta = with lib; {
    description = "IBM Decision Optimization CPLEX Modeling for Python";
    homepage = "https://onboarding-oaas.docloud.ibmcloud.com/software/analytics/docloud/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
