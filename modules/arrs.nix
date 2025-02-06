{ config, pkgs, ... }:
let
  user = config.services.deluge.user;
  group = config.services.deluge.group;
in
{
  environment.systemPackages = [ pkgs.cross-seed ];

  systemd.services.cross-seed = {
    description = "cross-seed";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cross-seed}/bin/cross-seed daemon";
      User = user;
      Group = group;
    };
  };

  services.autobrr = {
    enable = true;
    secretFile = "/var/lib/autobrr/secret";
    settings = {
      host = "127.0.0.1";
      port = "7474";
    };
  };

  services.sonarr = {
    enable = true;
    inherit user group;
  };

  services.radarr = {
    enable = true;
    inherit user group;
  };

  services.lidarr = {
    enable = true;
    inherit user group;
  };

  services.readarr = {
    enable = true;
    inherit user group;
  };

  services.bazarr = {
    enable = true;
    inherit user group;
  };

  services.prowlarr.enable = true;
  services.jellyseerr.enable = true;

  # Overseerr is fine to be accessed externally.
  services.cloudflared.tunnels.mars.ingress."overseerr.pta2002.com" = "http://localhost:${toString config.services.jellyseerr.port}";

  systemd.tmpfiles.settings."10-media" = {
    "/mnt/data/movies".d = {
      group = "data";
      user = config.services.radarr.user;
      mode = "0775";
    };
    "/mnt/data/tv".d = {
      group = "data";
      user = config.services.sonarr.user;
      mode = "0775";
    };
    "/mnt/data/music".d = {
      group = "data";
      user = config.services.lidarr.user;
      mode = "0775";
    };
    "/mnt/data/books".d = {
      group = "data";
      user = config.services.readarr.user;
      mode = "0775";
    };
  };

  proxy.services = {
    sonarr = "localhost:8989";
    radarr = "localhost:7878";
    lidarr = "localhost:8686";
    readarr = "localhost:8787";
    prowlarr = "localhost:9696";
    bazarr = "localhost:${toString config.services.bazarr.listenPort}";
    overseerr = "localhost:${toString config.services.jellyseerr.port}";
    autobrr = "localhost:${toString config.services.autobrr.settings.port}";
  };

  # Remove when https://github.com/NixOS/nixpkgs/issues/360592 is done
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];
}
