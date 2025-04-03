{ config, lib, ... }:
let
  group = "data";

  arrSecrets = name: {
    "${name}Key".rekeyFile = ../../secrets/arrs/${name}Key.age;
    "${name}Env" = {
      generator = {
        dependencies = [ config.age.secrets."${name}Key" ];
        tags = [ "arrs" ];
        script =
          {
            lib,
            decrypt,
            deps,
            ...
          }:
          let
            dep = lib.head deps;
          in
          ''
            echo "${lib.strings.toUpper name}__AUTH__APIKEY=$(${decrypt} ${lib.escapeShellArg dep.file})"
          '';
      };
    };
  };
in
{
  imports = [
    ../../modules/servarr
  ];

  services.sonarr = {
    enable = true;
    inherit group;
    environmentFiles = [ config.age.secrets.sonarrEnv.path ];
    settings.auth.method = "External";
  };

  services.radarr = {
    enable = true;
    inherit group;
    environmentFiles = [ config.age.secrets.radarrEnv.path ];
    settings.auth.method = "External";
  };

  services.lidarr = {
    enable = true;
    inherit group;
    environmentFiles = [ config.age.secrets.lidarrEnv.path ];
    settings.auth.method = "External";
  };

  services.readarr = {
    enable = true;
    inherit group;
    environmentFiles = [ config.age.secrets.readarrEnv.path ];
    settings.auth.method = "External";
  };

  services.bazarr = {
    enable = true;
    inherit group;
  };

  age.secrets = lib.mkMerge [
    (arrSecrets "prowlarr")
    (arrSecrets "sonarr")
    (arrSecrets "radarr")
    (arrSecrets "lidarr")
    (arrSecrets "readarr")
  ];

  services.prowlarr = {
    enable = true;
    environmentFiles = [ config.age.secrets.prowlarrEnv.path ];

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

  proxy.services =
    (lib.mapAttrs
      (name: addr: {
        inherit addr;
        auth = {
          enable = true;
          excluded = [ "/api" ];
        };
      })
      {
        sonarr = "localhost:8989";
        radarr = "localhost:7878";
        lidarr = "localhost:8686";
        readarr = "localhost:8787";
      }
    )
    // {
      # No auth for prowlarr
      prowlarr.addr = "localhost:9696";
      # No exclusions for bazarr
      bazarr = {
        addr = "localhost:${toString config.services.bazarr.listenPort}";
        auth.enable = true;
      };
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
