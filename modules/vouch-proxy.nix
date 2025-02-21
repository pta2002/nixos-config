{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.vouch-proxy;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    ;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options.services.vouch-proxy = {
    enable = mkEnableOption "vouch-proxy";
    package = mkPackageOption pkgs "vouch-proxy" { };

    jwtSecretFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "File to store the JWT secret";
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;

        options = {
          vouch = {
            listen = mkOption {
              type = types.str;
              default = "0.0.0.0";
              description = "Address to bind to, or alternatively, path to the socket to listen on.";
            };

            port = mkOption {
              type = types.nullOr types.int;
              default = 9090;
              description = "Port to listen on";
            };
          };
        };
      };

      default = { };
      description = ''
        Settings for vouch-proxy.
      '';
    };
  };

  config =
    let
      configPath = settingsFormat.generate "config.yml" cfg.settings;
    in
    mkIf cfg.enable {
      systemd.services.vouch-proxy = {
        description = "Vouch-proxy";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          # vouch-proxy will try to store the JWT secret in the same directory as the config file, so we need to move it.
          ExecStartPre = lib.mkMerge [
            ''
              +${pkgs.coreutils}/bin/cp "${configPath}" ''${STATE_DIRECTORY}/config.yml
            ''
            (mkIf (cfg.jwtSecretFile != null) ''
              +${pkgs.coreutils}/bin/cp "${cfg.jwtSecretFile}" ''${STATE_DIRECTORY}/secret
            '')
          ];
          ExecStart = ''
            ${lib.getExe cfg.package} -config ''${STATE_DIRECTORY}/config.yml
          '';
          DynamicUser = true;
          StateDirectory = "vouch-proxy";
          LoadCredentials = mkIf (cfg.jwtSecretFile != null) "jwtSecret:${cfg.jwtSecretFile}";
        };
      };
    };

  meta = {
    maintainers = with lib.maintainers; [ pta2002 ];
  };
}
