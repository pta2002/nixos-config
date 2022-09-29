{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./argoweb.nix
  ];

  age.secrets.yarr = {
    file = ../secrets/yarr.age;
    owner = "yarr";
  };

  services.argoWeb = {
    enable = true;
    ingress = [
      {
        hostname = "yarr.pta2002.com";
        service = "http://localhost:7070";
      }
    ];
  };

  systemd.services.yarr = {
    description = "yarr";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${inputs.extras.packages.${pkgs.system}.yarr}/bin/yarr -auth-file ${config.age.secrets.yarr.path}";
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
