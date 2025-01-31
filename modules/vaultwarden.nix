{ config, ... }:
{
  # It's only accessible through tailscale for security.
  proxy.services.vault = "localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}";

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.c.pta2002.com";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
