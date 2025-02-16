{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cross-seed;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.cross-seed = {
    enable = mkEnableOption "cross-seed";

    package = mkPackageOption pkgs "cross-seed" { };

    user = mkOption {
      type = types.str;
      default = "cross-seed";
      description = "User to run cross-seed as.";
    };

    group = mkOption {
      type = types.str;
      default = "cross-seed";
      description = "Group to run cross-seed as.";
    };

    configDir = mkOption {
      type = types.path;
      default = "/var/lib/cross-seed";
      description = "Cross-seed config directory";
    };

    settings = mkOption {
      default = { };
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          dataDirs = mkOption {
            type = types.listOf types.path;
            default = [ ];
          };

          linkDirs = mkOption {
            type = types.listOf types.path;
            default = [ ];
          };

          torrentDir = mkOption {
            type = types.path;
          };

          outputDir = mkOption {
            type = types.path;
          };
        };
      };
    };

    settingsFile = lib.mkOption {
      default = null;
      type = types.nullOr types.path;
    };
  };

  # Config file should be in $CONFIG_DIR/config.js.
  config =
    let
      jsonSettingsFile = settingsFormat.generate "settings.json" cfg.settings;
      secretSettingsSegment =
        lib.optionalString (cfg.settingsFile != null) # js
          ''
            const path = require("node:path");
            const secret_settings_json = path.join(process.env.CREDENTIALS_DIRECTORY, "secretSettingsFile");
            Object.assign(loaded_settings, JSON.parse(fs.readFileSync(secret_settings_json, "utf8")));
          '';
      javascriptConfig =
        pkgs.writeText "config.js" # js
          ''
            "use strict";
            const fs = require("fs");
            const settings_json = "${jsonSettingsFile}";
            let loaded_settings = JSON.parse(fs.readFileSync(settings_json, "utf8"));
            ${secretSettingsSegment}
            module.exports = loaded_settings;
          '';
    in
    lib.mkIf (cfg.enable) {
      system.activationScripts.cross-seed = ''
        install -d -m 700 -o '${cfg.user}' -g '${cfg.group}' '${cfg.configDir}'
      '';

      systemd.services.cross-seed = {
        description = "cross-seed";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        environment.CONFIG_DIR = cfg.configDir;
        unitConfig = {
          # Unfortunately, we can not protect these if we are to hardlink between them, as they need to be on the same volume for hardlinks to work.
          RequiresMountsFor = lib.flatten [
            cfg.settings.dataDirs
            cfg.settings.linkDirs
          ];
        };
        serviceConfig = {
          ExecStartPre = [
            (pkgs.writeShellScript "cross-seed-prestart" ''
              set -eux
              install -D -m 600 -o '${cfg.user}' -g '${cfg.group}' '${javascriptConfig}' '${cfg.configDir}/config.js'
            '')
          ];
          ExecStart = "${lib.getExe cfg.package} daemon";
          User = cfg.user;
          Group = cfg.group;

          LoadCredential = lib.mkIf (cfg.settingsFile != null) "secretSettingsFile:${cfg.settingsFile}";

          StateDirectory = "cross-seed";

          ReadWritePaths = [ cfg.settings.outputDir ];

          ReadOnlyPaths = [
            cfg.settings.torrentDir
          ];
        };
      };
    };
}
