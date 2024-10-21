{ pkgs, config, ... }:
{
  age.secrets.transmission = {
    file = ../secrets/transmission.age;
    owner = config.services.transmission.user;
  };

  services.cloudflared.tunnels."mars".ingress."transmission.pta2002.com" = "http://localhost:9091";

  services.transmission = {
    enable = true;
    user = "transmission";

    home = "/var/lib/transmission";

    settings.download-dir = "/mnt/data/torrents";
    settings.incomplete-dir = "/mnt/data/torrents/.incomplete";
    settings.rpc-authentication-required = true;
    settings.rpc-host-whitelist = "transmission.pta2002.com";

    openPeerPorts = true;

    downloadDirPermissions = "777";
    settings.umask = 2;

    credentialsFile = config.age.secrets.transmission.path;
  };

  systemd.services.transmission = {
    requires = [ "mnt-data.mount" ];
  };

  users.users.${config.services.transmission.user} = {
    home = config.services.transmission.home;
    createHome = true;
  };
}
