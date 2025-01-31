{ config, pkgs, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  age.secrets.yarr = {
    file = ../secrets/yarr.age;
    owner = "yarr";
  };

  proxy.services.yarr = "localhost:7070";

  systemd.services.yarr = {
    description = "yarr";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.yarr}/bin/yarr -auth-file ${config.age.secrets.yarr.path}";
      Type = "simple";
      User = "yarr";
      Group = "yarr";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      LimitNPROC = 512;
      LimitNOFILE = 1048576;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "full";
      ReadWriteDirectories = "/var/lib/yarr";
    };
  };

  users.users.yarr = {
    home = "/var/lib/yarr";
    createHome = true;
    isSystemUser = true;
    group = "yarr";
  };

  users.groups.yarr = { };
}
