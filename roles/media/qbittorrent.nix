{
  pkgs,
  lib,
  config,
  ...
}:
{
  age.secrets.qui-secret = {
    rekeyFile = ../../secrets/qui-secret.age;
    generator.script = { pkgs, ... }: "${pkgs.openssl}/bin/opoenssl rand -hex 32";
  };

  services.qbittorrent = {
    enable = true;

    user = "qbittorrent";
    group = "data";

    webuiPort = 9876;

    serverConfig = {
      Preferences.WebUI = {
        Username = "admin";
        Password_PBKDF2 = "@ByteArray(+oCodC4yCdKyEYKzkBs0Cg==:Srrfd7ftdJMav06xwYocajEm3PkpisVLrWQmie32IkcOo9/Y7jFkJG25zHYr3Tzvj3WdF2Egfk6NwNZmTNJOjQ==)";
      };

      BitTorrent.Session = {
        AddTorrentStopped = false;
        DHTEnabled = false;
        LSDEnabled = false;
        PeXEnabled = false;
        MaxConnections = -1;
        MaxConnectionsPerTorrent = -1;
        MaxUploads = -1;
        MaxUploadsPerTorrent = -1;
        QueueingSystemEnabled = false;
        Port = 41821;
        UseAlternativeGlobalSpeedLimit = false;
        DefaultSavePath = "/srv/media/torrents";
      };

      Network.PortForwardingEnabled = false;
    };

    openFirewall = true;
  };

  # Ensure qbittorrent starts only after /srv/media is mounted
  systemd.services.qbittorrent = {
    after = [ "srv-media.mount" ];
    requires = [ "srv-media.mount" ];
  };

  services.qui = {
    enable = true;
    secretFile = config.age.secrets.qui-secret.path;
  };

  systemd.tmpfiles.settings."10-torrents" = {
    "/srv/media/torrents".d = {
      group = "data";
      user = config.services.qbittorrent.user;
      mode = "0775";
    };
  };

  networking.firewall.allowedTCPPorts = [ 41821 ];
  networking.firewall.allowedUDPPorts = [ 41821 ];

  proxy.services.qui = "127.0.0.1:7476";
}
