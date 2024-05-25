{ ... }: {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.cloudflared.tunnels.mars = {
    ingress."plex.pta2002.com" = "http://localhost:32400";
  };
}
