{ pkgs, config, ... }:
{
  imports = [
    ../../modules/yarr.nix
    ../../modules/fava.nix
    ../../modules/vaultwarden.nix
    ../../modules/proxy.nix
  ];

  proxy = {
    enable = true;
    domain = "c.pta2002.com";
    ipv4 = "100.86.136.44";
    ipv6 = "fd7a:115c:a1e0:ab12:4843:cd96:6256:882c";
    environmentFile = config.age.secrets.caddy-mars.path;
  };

  age.secrets.caddy-mars.rekeyFile = ../../secrets/caddy-mars.age;

  environment.systemPackages = with pkgs; [
    git
    docker-compose
    nh
    htop
  ];

  networking.hostName = "cloudy";

  virtualisation.docker.enable = true;

  users.users.pta2002.extraGroups = [
    "docker"
  ];

  system.stateVersion = "22.11";
  services.tailscale.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "pta2002@pta2002.com";
  };
}
