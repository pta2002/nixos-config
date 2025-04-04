{ pkgs, ... }:
{
  home.packages = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        numpy
        scipy
        matplotlib
        tensorflow
        black
        tensorflow
        ipykernel
        keras
        pip
        notebook
      ]
    ))
  ];
}
