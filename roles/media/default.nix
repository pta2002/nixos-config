{ config, ... }: {
  imports = [
    ../../modules/qbittorrent.nix
  ];

  services.qbittorrent.enable = true;
  services.qbittorrent.user = config.services.deluge.user;
  services.qbittorrent.group = config.services.deluge.group;
  services.qbittorrent.home = "/var/lib/deluge";
  services.qbittorrent.downloadDir = "/mnt/data/torrents/";
  services.qbittorrent.webuiPort = 8844;

  users.groups.data = { };
  users.users.pta2002.extraGroups = [ "data" ];
}
