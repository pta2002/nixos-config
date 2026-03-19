{
  pkgs,
  ...
}:
let
  ledgerFile = "/var/lib/fava/ledger.beancount";
  fava-pkg = pkgs.python3.buildEnv.override {
    extraLibs = [
      (pkgs.python3Packages.toPythonModule (pkgs.callPackage ../configs/beancount_importers { }))
      (pkgs.python3Packages.toPythonModule (
        pkgs.fava.overrideAttrs (prev: {
          # src = pkgs.fetchurl {
          #   url = "https://github.com/pta2002/fava/releases/download/v1.27.3-pwa/fava-1.27.4.dev4+g7313467f.tar.gz";
          #   sha256 = "0w4dlxq180m466dnwl0jlfmc7qlnx9yailgpzrg3ixibn1vday5a";
          # };
          propagatedBuildInputs = prev.propagatedBuildInputs ++ [
            pkgs.python3Packages.watchfiles
          ];

          doCheck = false;
          doInstallCheck = false;
        })
      ))
    ];
  };
in
{
  systemd.services.fava = {
    description = "fava";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${fava-pkg}/bin/fava ${ledgerFile}";
      Type = "simple";
      User = "fava";
      Group = "fava";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "full";
      ReadWriteDirectories = "/var/lib/fava";
    };
  };

  proxy.services.fava = "localhost:5000";

  users.users.fava = {
    home = "/var/lib/fava";
    createHome = true;
    isSystemUser = true;
    group = "yarr";
  };

  users.groups.fava = { };
}
