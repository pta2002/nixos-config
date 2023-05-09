{ inputs, pkgs, ... }: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  musnix.enable = true;
}
