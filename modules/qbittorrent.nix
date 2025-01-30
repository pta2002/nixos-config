{ config, lib, pkgs, ... }:
let
  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    enable = lib.mkEnableOption "qbittorrent";

    package = lib.mkPackageOption pkgs "qbittorrent" {
      default = "qbittorrent-nox";
      example = "qbittorrent-enhanced";
    };

    webuiPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port under which the web UI runs.";
    };

    downloadDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/qbittorrent/Downloads";
    };

    home = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/qbittorrent";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
      description = "User acount under which qBittorrent runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
      description = "Group acount under which qBittorrent runs.";
    };
  };

  config = lib.mkIf cfg.enable
    {
      environment.systemPackages = [ pkgs.qbittorrent-cli ];

      networking.firewall.allowedTCPPorts = [ 42044 ];
      networking.firewall.allowedUDPPorts = [ 42044 ];

      proxy.services.qbittorrent = "localhost:${toString cfg.webuiPort}";

      systemd.services.qbittorrent = {
        description = "qBittorrent BitTorrent Service";
        after = [ "network.target" ];

        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package.meta.mainProgram} --webui-port=${toString cfg.webuiPort}";
          User = cfg.user;
          Group = cfg.group;

          # RuntimeDirectory = [ (baseNameOf rootDir) ];
          # RuntimeDirectoryMode = "755";
          #
          # UMask = "0066";
          #
          # RootDirectory = rootDir;
          # RootDirectoryStartOnly = true;
          #
          # BindPaths = [
          #   "${cfg.home}"
          #   cfg.downloadDir
          #   "/run"
          # ];
          #
          # BindReadOnlyPaths = [
          #   builtins.storeDir
          # ];
        };
      };

      users.users = lib.optionalAttrs (cfg.user == "qbittorrent") {
        qbittorrent = {
          group = cfg.group;
          description = "qBittorrent user";
          home = cfg.home;
          isSystemUser = true;
          createHome = true;
        };
      };

      users.groups = lib.optionalAttrs (cfg.group == "qbittorrent") {
        qbittorrent = { };
      };
    }
  ;
}
