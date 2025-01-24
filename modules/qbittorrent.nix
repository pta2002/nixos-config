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

    webui-port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port under which the web UI runs.";
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.qbittorrent-cli ];

    systemd.services.qbittorrent = {
      description = "qBittorrent BitTorrent Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/qbittorrent-nox --webui-port=${toString cfg.webui-port}";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    users.users = lib.optionalAttrs (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        # uid = config.ids.uids.qbittorrent;
        description = "qBittorrent user";
        home = cfg.home;
        isSystemUser = true;
        createHome = true;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "qbittorrent") {
      qbittorrent = {
        # gid = config.ids.gids.qbittorrent;
      };
    };
  };
}
