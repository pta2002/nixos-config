# Backup service, powered by restic.
{ config, lib, ... }:
{
  options.common.backups.paths = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    description = "Paths to back up through restic.";
    default = [ ];
  };

  config = {
    age.secrets.restic-password.file = ../secrets/restic-password.age;
    age.secrets.rclone-config.file = ../secrets/rclone-config.age;

    services.restic.backups = {
      b2 = {
        repository = "rclone:backblaze:/pta2002-rclone";
        initialize = true;
        passwordFile = config.age.secrets.restic-password.path;
        paths = config.common.backups.paths;
        rcloneConfigFile = config.age.secrets.rclone-config.path;

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
  };
}
