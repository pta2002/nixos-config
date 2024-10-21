{ python3 }:
python3.pkgs.buildPythonPackage rec {
  name = "beancount_importers";
  src = ./.;
  format = "pyproject";

  propagatedBuildInputs = with python3.pkgs.pythonPackages; [
    beancount
    pypdf
  ];

  doCheck = false;
  doInstallCheck = false;

  nativeBuildInputs = with python3.pkgs; [ poetry-core ];
}
