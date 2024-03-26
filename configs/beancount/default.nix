{ pkgs, ... }:
pkgs.buildPythonPackage rec {
    name = "beancount";
    src = ./.;
    propagatedBuildInputs = with pkgs.python3Packages; [
        beancount
        pypdf
    ];
}
