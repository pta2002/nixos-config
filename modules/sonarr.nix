{ pkgs, config, ... }:
{
  services.sonarr = {
    enable = true;
    user = "rtorrent";
    group = "rtorrent";
  };

  services.radarr = {
    enable = true;
    user = "rtorrent";
    group = "rtorrent";
  };

  services.jackett = {
    enable = true;
    user = "rtorrent";
    group = "rtorrent";
  };

  services.argoWeb = {
    ingress."sonarr.pta2002.com" = "http://localhost:8989";
    ingress."radarr.pta2002.com" = "http://localhost:7878";
    ingress."jackett.pta2002.com" = "http://localhost:9117";
  };
}