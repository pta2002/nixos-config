{ pkgs, config, ... }:
{
  services.deluge = {
    enable = true;
    declarative = true;
    openFirewall = true;
    web.enable = true;
    authFile = config.age.secrets.deluge.path;

    config.download_location = "/mnt/data/torrents";
    config.enabled_plugins = [ "Label" ];
    config.copy_torrent_file = true;
    config.allow_remote = true;
    config.max_active_seeding = -1;
    config.max_upload_slots_global = -1;
    config.max_active_limit = -1;
    config.max_active_downloading = -1;
    config.random_port = false;
  };

  # Deluge
  networking.firewall.allowedTCPPorts = [ 58846 ];
  networking.firewall.allowedUDPPorts = [ 58846 ];

  age.secrets.deluge = {
    file = ../secrets/deluge.age;
    owner = config.services.deluge.user;
  };

  services.cloudflared.tunnels."mars".ingress = {
    "deluge.pta2002.com" = "http://localhost:${builtins.toString config.services.deluge.web.port}";
    "flood.pta2002.com" = "http://localhost:${builtins.toString config.services.flood.port}";
  };

  systemd.services.deluged = {
    requires = [ "mnt-data.mount" ];
  };

  # Mediainfo is nice to have available for flood.
  services.flood.enable = true;
  environment.systemPackages = [ pkgs.mediainfo ];
}
