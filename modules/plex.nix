{ ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  proxy.services.plex = "localhost:32400";

  services.cloudflared.tunnels.mars = {
    ingress."plex.pta2002.com" = "http://localhost:32400";
  };
}
