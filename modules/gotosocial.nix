{ config, pkgs, lib, inputs, ... }:
let
  configFile = pkgs.writeTextFile {
    name = "gotosocial.yaml";
    text = lib.toJSON {
      host = "localhost";
      db-type = "sqlite";
      db-address = "sqlite.db";
      storage-local-base-path = "/var/lib/gotosocial";
      letsencrypt-enabled = false;
      port = 8888;
    };
  };
in
{
  imports = [
    ./argoweb.nix
  ];

  users.users.gotosocial = {
    isSystemUser = true;
    group = "gotosocial";
    home = "/var/lib/gotosocial";
  };

  systemd.services.gotosocial = {
    description = "gotosocial";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "on-failure";
      User = "gotosocial";
      StateDirectory = "gotosocial";
      ExecStart = "${inputs.extras.packages.${pkgs.system}.gotosocial}/gotosocial --config-path ${configFile} server start";

      WorkingDirectory = "/var/lib/gotosocial";
    };
  };
}
