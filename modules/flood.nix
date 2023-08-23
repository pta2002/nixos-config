{ pkgs, config, ... }:
let
  floodPort = 48328;
in
{
  imports = [
    ./argoweb.nix
  ];

  age.secrets.transmission = {
    file = ../secrets/transmission.age;
    owner = "transmission";
  };

  # services.argoWeb = {
  #   ingress."flood.pta2002.com" = "http://localhost:${toString floodPort}";
  # };

  services.argoWeb = {
    ingress."transmission.pta2002.com" = "http://localhost:9091";
  };


  services.transmission = {
    enable = true;
    user = "transmission";

    home = "/var/lib/transmission";

    settings.download-dir = "/mnt/data/torrents";
    settings.incomplete-dir = "/mnt/data/torrents/.incomplete";
    settings.rpc-authentication-required = true;
    settings.rpc-host-whitelist = "transmission.pta2002.com";

    openPeerPorts = true;

    downloadDirPermissions = "777";
    settings.umask = 2;

    credentialsFile = config.age.secrets.transmission.path;
  };

  users.users.${config.services.transmission.user} = {
    home = config.services.transmission.home;
    createHome = true;
  };

  # systemd.services.flood = {
  #   enable = false;
  #   wantedBy = [ "default.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.flood}/bin/flood --port=${toString floodPort} --rundir=${config.services.rtorrent.dataDir}";
  #     User = config.services.transmission.user;
  #     Group = config.services.transmission.group;
  #     Restart = "on-failure";
  #   };
  # };
}
