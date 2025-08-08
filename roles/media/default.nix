{ config, ... }:
{
  # TODO: Re-enable this is desired.
  # services.qbittorrent.enable = true;
  # services.qbittorrent.user = config.services.deluge.user;
  # services.qbittorrent.group = config.services.deluge.group;
  # services.qbittorrent.home = "/var/lib/deluge";
  # services.qbittorrent.downloadDir = "/mnt/data/torrents/";
  # services.qbittorrent.webuiPort = 8844;

  services.jellyseerr.enable = true;

  # Overseerr is fine to be accessed externally.
  services.cloudflared.tunnels.mars.ingress."overseerr.pta2002.com" =
    "http://localhost:${toString config.services.jellyseerr.port}";
}
