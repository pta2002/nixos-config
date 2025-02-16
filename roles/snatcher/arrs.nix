{ config, ... }:
let
  group = "data";
in
{
  imports = [
    ../../modules/servarr
  ];

  services.sonarr = {
    enable = true;
    inherit group;
  };

  services.radarr = {
    enable = true;
    inherit group;
  };

  services.lidarr = {
    enable = true;
    inherit group;
  };

  services.readarr = {
    enable = true;
    inherit group;
  };

  services.bazarr = {
    enable = true;
    inherit group;
  };

  age.secrets.prowlarrKey.file = ../../secrets/arrs/prowlarrKey.age;
  age.secrets.sonarrKey.file = ../../secrets/arrs/sonarrKey.age;
  age.secrets.radarrKey.file = ../../secrets/arrs/radarrKey.age;
  age.secrets.lidarrKey.file = ../../secrets/arrs/lidarrKey.age;
  age.secrets.readarrKey.file = ../../secrets/arrs/readarrKey.age;

  services.prowlarr = {
    enable = true;

    settings = {
      url = "https://prowlarr.p.pta2002.com";
      apiKeyFile = config.age.secrets.prowlarrKey.path;

      applications = {
        sonarr = {
          url = "https://sonarr.p.pta2002.com";
          apiKeyFile = config.age.secrets.sonarrKey.path;
        };

        radarr = {
          url = "https://radarr.p.pta2002.com";
          apiKeyFile = config.age.secrets.radarrKey.path;
        };

        lidarr = {
          url = "https://lidarr.p.pta2002.com";
          apiKeyFile = config.age.secrets.lidarrKey.path;
        };

        readarr = {
          url = "https://readarr.p.pta2002.com";
          apiKeyFile = config.age.secrets.readarrKey.path;
        };
      };
    };
  };

  systemd.tmpfiles.settings."10-media" = {
    "/srv/media/movies".d = {
      group = "data";
      inherit (config.services.radarr) user;
      mode = "0775";
    };
    "/srv/media/tv".d = {
      group = "data";
      inherit (config.services.sonarr) user;
      mode = "0775";
    };
    "/srv/media/music".d = {
      group = "data";
      inherit (config.services.lidarr) user;
      mode = "0775";
    };
    "/srv/media/books".d = {
      group = "data";
      inherit (config.services.readarr) user;
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
  };

  common.backups.paths = [
    "/var/lib/lidarr"
    "/var/lib/readarr"
    "/var/lib/radarr"
    "/var/lib/sonarr"
    "/var/lib/bazarr"
    "/var/lib/private/prowlarr"
  ];
}
