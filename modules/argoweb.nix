{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.argoWeb;
in
{
  options.services.argoWeb = {
    enable = mkEnableOption "Cloudflare Argo Tunnel";

    ingress = mkOption {
      default = [ ];
      type = types.listOf (types.submodule {
        options = {
          hostname = mkOption {
            type = types.nullOr types.str;
            default = null;
          };

          service = mkOption {
            type = types.str;
          };
        };
      });
    };

    dataDir = mkOption {
      default = "/var/lib/argoWeb";
      type = types.path;
      description = ''
        The data directory, for storing credentials.
      '';
    };

    package = mkOption {
      default = pkgs.cloudflared;
      defaultText = "pkgs.cloudflared";
      type = types.package;
      description = "cloudflared package to use.";
    };
  };

  config =
    let
      config = {
        tunnel = "cloudytunnel";
        # "credentials-file" = config.age.secrets.cloudflared.path;

        ingress = cfg.ingress;
      };

      configfile = pkgs.writeTextFile {
        name = "cloudflared.yaml";
        text = builtins.toJSON config;
      };
    in
    mkIf cfg.enable {
      age.secrets.cloudflared.path = ../secrets/cloudflared.json.age;
      systemd.services.argoWeb = {
        description = "Cloudflare Argo Tunnel";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/cloudflared --config ${configfile} --no-autoupdate tunnel run";
          Type = "simple";
          User = "argoweb";
          Group = "argoweb";
          Restart = "on-failure";
          RestartSec = "5s";
          NoNewPrivileges = true;
          LimitNPROC = 512;
          LimitNOFILE = 1048576;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "full";
          ReadWriteDirectories = cfg.dataDir;
        };
      };
    };
}
