{ pkgs, config, ... }:
{
  imports = [
    # ../../modules/argoweb.nix
    ../../modules/yarr.nix
    ../../modules/files.nix
    # Disabled for now, fava is incompatible with beancount3
    # ../../modules/fava.nix
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

  age.secrets.caddy-mars.file = ../../secrets/caddy-mars.age;

  environment.systemPackages = with pkgs; [
    git
    docker-compose
    nh
    htop
  ];

  networking.hostName = "cloudy";

  virtualisation.docker.enable = true;

  users.users.pta2002.extraGroups = [
    "argoweb"
    "docker"
  ];

  system.stateVersion = "22.11";
  services.tailscale.enable = true;

  # Stuff for argo
  # age.secrets.cloudflared = {
  #   file = ../../secrets/cloudflared.json.age;
  #   owner = "argoweb";
  # };
  #
  # age.secrets.cert = {
  #   file = ../../secrets/cert.pem.age;
  #   owner = "argoweb";
  # };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pta2002@pta2002.com";
  };
}
