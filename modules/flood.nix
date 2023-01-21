{ pkgs, config, ... }:
let
  floodPort = 48328;
in
{
  imports = [
    ./argoweb.nix
  ];

  services.argoWeb = {
    ingress."flood.pta2002.com" = "http://localhost:${floodPort}";
  };

  services.rtorrent = {
    enable = true;
  };

  systemd.services.flood = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.flood}/bin/flood --port=${toString fllodPort} --rundir=${config.services.rtorrent.dataDir} --rtsocket=${config.services.rtorrent.rpcSocket}";
      User = config.services.rtorrent.user;
      Group = config.services.rtorrent.group;
      Restart = "on-failure";
    };
  };
}
