{ config, pkgs, lib, ... }: {
  imports = [
    ./argoweb.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.argoWeb = {
    enable = true;
    ingress = [
      {
        hostname = "yarr.pta2002.com";
        service = "http://localhost:7070";
      }
    ];
  };
}
