{
  services.plex = {
    enable = true;
    openFirewall = true;
    group = "data";
  };

  proxy.services.plex = "localhost:32400";
}
