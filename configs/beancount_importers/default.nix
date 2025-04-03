{ python3, python3Packages }:
python3.pkgs.buildPythonPackage rec {
  name = "beancount_importers";
  src = ./.;
  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [
    beancount
    pypdf
  ];

  doCheck = false;
  doInstallCheck = false;

  nativeBuildInputs = with python3.pkgs; [ poetry-core ];
}
