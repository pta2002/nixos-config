{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.dispatcharr;
in
{
  options = {
    services.dispatcharr = {
      enable = lib.mkEnableOption "Dispatcharr";
    };
  };

  config = lib.mkIf cfg.enable {
    proxy.services.iptv = "localhost:9191";

    users.users.dispatcharr = {
      isSystemUser = true;
      home = "/var/lib/dispatcharr";
      createHome = true;
      group = "dispatcharr";
      linger = true;
    };

    users.groups.dispatcharr = { };

    virtualisation.oci-containers.containers.dispatcharr = {
      image = "ghcr.io/dispatcharr/dispatcharr:latest";
      pull = "newer";

      ports = [ "9191:9191" ];
      environment = {
        DISPATCHARR_ENV = "aio";
        REDIS_HOST = "localhost";
        CELERY_BROKER_URL = "redis://localhost:6379/0";
        DISPATCHARR_LOG_LEVEL = "info";
      };

      volumes = [ "dispatcharr:/data" ];

      # podman.user = "dispatcharr";
    };
  };
}
