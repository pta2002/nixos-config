{ pkgs, ... }: {
  imports = [
    ./argoweb.nix
  ];

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.argoWeb = {
    ingress."plex.pta2002.com" = "http://localhost:32400";
  };
}
