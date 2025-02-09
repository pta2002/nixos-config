{ ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
    group = "data";
  };

  proxy.services.plex = "localhost:32400";

  services.cloudflared.tunnels.mars = {
    ingress."plex.pta2002.com" = "http://localhost:32400";
  };
}
