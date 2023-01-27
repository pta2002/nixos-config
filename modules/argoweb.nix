{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.argoWeb;
in
{
  options.services.argoWeb = {
    enable = mkEnableOption "Cloudflare Argo Tunnel";

    ingress = mkOption {
      default = { };
      type = types.attrsOf types.str;
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

    tunnel = mkOption {
      default = "cloudytunnel";
      type = types.str;
      description = "Tunnel name";
    };

    originCert = mkOption {
      default = config.age.secrets.cert.path;
      type = types.path;
      description = "Origin certificate";
    };

    credentialsFile = mkOption {
      default = config.age.secrets.cloudflared.path;
      type = types.path;
      description = "Credentials file";
    };
  };

  config =
    let
      ingress = lib.mapAttrsToList (hostname: service: { inherit hostname service; }) cfg.ingress;

      argoconfig = {
        tunnel = cfg.tunnel;
        origincert = cfg.originCert;
        "credentials-file" = cfg.credentialsFile;

        ingress = ingress ++ [
          { service = "http_status:404"; }
        ];
      };

      configfile = pkgs.writeTextFile {
        name = "cloudflared.yaml";
        text = builtins.toJSON argoconfig;
      };
    in
    mkIf cfg.enable {
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

      users.users.argoweb = {
        home = "/var/lib/argoWeb";
        createHome = true;
        isSystemUser = true;
        group = "argoweb";
      };

      users.groups.argoweb = { };
    };
}
