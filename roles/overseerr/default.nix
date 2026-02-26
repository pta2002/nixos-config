{ config, ... }:
{
  services.jellyseerr.enable = true;

  # Overseerr is fine to be accessed externally.
  services.cloudflared.tunnels.mars.ingress."overseerr.pta2002.com" =
    "http://localhost:${toString config.services.jellyseerr.port}";
}
