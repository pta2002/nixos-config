{ config, ... }:
{
  age.secrets.transmission = {
    file = ../secrets/transmission.age;
    owner = config.services.transmission.user;
  };

  services.cloudflared.tunnels."mars".ingress = {
    "transmission.pta2002.com" = "http://localhost:9091";
    "flood.pta2002.com" = "http://localhost:${builtins.toString config.services.flood.port}";
  };

  services.transmission = {
    enable = true;
    user = "transmission";

    home = "/var/lib/transmission";

    settings = {
      download-dir = "/mnt/data/torrents";
      incomplete-dir = "/mnt/data/torrents/.incomplete";
      rpc-authentication-required = true;
      rpc-host-whitelist = "transmission.pta2002.com,localhost";
      rpc-whitelist = "*";
      download-queue-enabled = false;
    };

    openPeerPorts = true;

    downloadDirPermissions = "777";
    settings.umask = 2;

    credentialsFile = config.age.secrets.transmission.path;
  };

  systemd.services.transmission = {
    requires = [ "mnt-data.mount" ];
  };

  services.flood.enable = true;

  users.users.${config.services.transmission.user} = {
    home = config.services.transmission.home;
    createHome = true;
  };
}
