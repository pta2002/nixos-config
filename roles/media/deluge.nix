{ pkgs, config, ... }:
{
  services.deluge = {
    enable = true;
    declarative = true;
    openFirewall = true;
    web.enable = true;
    authFile = config.age.secrets.deluge.path;

    user = "deluge";
    group = "data";

    config.download_location = "/srv/media/torrents";
    config.enabled_plugins = [ "Label" ];
    config.copy_torrent_file = true;
    config.allow_remote = true;
    config.max_active_seeding = -1;
    config.max_upload_slots_global = -1;
    config.max_active_limit = -1;
    config.max_active_downloading = -1;
    config.random_port = false;
    config.listen_ports = [
      40901
      40901
    ];
  };

  users.users.deluge.extraGroups = [ "data" ];

  # Deluge
  networking.firewall.allowedTCPPorts = [ 58846 ];
  networking.firewall.allowedUDPPorts = [ 58846 ];

  age.secrets.deluge = {
    file = ../../secrets/deluge.age;
    owner = config.services.deluge.user;
  };

  proxy.services = {
    deluge = "localhost:${builtins.toString config.services.deluge.web.port}";
    flood = {
      addr = "localhost:${builtins.toString config.services.flood.port}";
      auth.enable = true;
    };
  };

  systemd.services.deluged = {
    unitConfig = {
      RequiresMountsFor = "/srv/media";
    };
  };

  systemd.tmpfiles.settings."10-torrents" = {
    "/srv/media/torrents".d = {
      group = "data";
      user = config.services.deluge.user;
      mode = "0775";
    };
  };

  # Mediainfo is nice to have available for flood.
  services.flood.enable = true;
  environment.systemPackages = [ pkgs.mediainfo ];
}
