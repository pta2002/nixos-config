{ pkgs, ... }:
{
  services.argoWeb = {
    enable = true;
    ingress."vault.pta2002.com" = "http://localhost:8222";
  };

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.pta2002.com";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
