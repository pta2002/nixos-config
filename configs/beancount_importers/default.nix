{ pkgs ? import <nixpkgs> {}, buildPythonPackage }:
pkgs.buildPythonPackage rec {
    name = "beancount_importers";
    src = ./.;
    propagatedBuildInputs = with pkgs.python3Packages; [
        beancount
        pypdf
    ];
}
