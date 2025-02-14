{ config, ... }:
let
  user = config.services.deluge.user;
  group = config.services.deluge.group;
in
{
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

  common.backups.paths = [
    "/var/lib/lidarr"
    "/var/lib/readarr"
    "/var/lib/radarr"
    "/var/lib/sonarr"
    "/var/lib/bazarr"
    "/var/lib/prowlarr"
    "/var/lib/jellyseerr"
    "/var/lib/private/prowlarr"
    "/var/lib/private/jellyseerr"
    "/var/lib/private/autobrr"
  ];

  imports = [
    ../../modules/cross-seed.nix
  ];

  services.cross-seed = {
    enable = true;
    inherit user group;
    settings = {
      dataDirs = [ "/srv/media/tv" "/srv/media/movies" ];
      linkDirs = [ "/srv/media/torrents/links" ];
      torrentDir = "/var/lib/deluge/.config/deluge/state";
      outputDir = "/var/lib/deluge/output";
      linkType = "hardlink";
      matchMode = "partial";
      skipRecheck = true;
      maxDataDepth = 3;
      includeSingleEpisodes = true;
      seasonFromEpisodes = 0.5;
      fuzzySizeThreshold = 0.02;
      action = "inject";
      duplicateCategories = true;
    };

    settingsFile = config.age.secrets.cross-seed.path;
  };

  age.secrets.cross-seed = {
    file = ../../secrets/cross-seed.json.age;
    owner = config.services.cross-seed.user;
    group = config.services.cross-seed.group;
  };
}
