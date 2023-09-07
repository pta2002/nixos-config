{ pkgs, ... }: {
  imports = [
    ./argoweb.nix
  ];

  services.jellyfin = {
    enable = true;
  };

  networking.firewall.enable = false;
}
