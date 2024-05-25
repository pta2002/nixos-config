{ pkgs, config, ... }:
{
  services.sonarr = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.radarr = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.jackett = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.cloudflared.tunnels.mars = {
    ingress."sonarr.pta2002.com" = "http://localhost:8989";
    ingress."radarr.pta2002.com" = "http://localhost:7878";
    ingress."jackett.pta2002.com" = "http://localhost:9117";
  };
}
