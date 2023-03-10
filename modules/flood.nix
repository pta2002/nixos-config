{ pkgs, config, ... }:
let
  floodPort = 48328;
in
{
  imports = [
    ./argoweb.nix
  ];

  services.argoWeb = {
    ingress."flood.pta2002.com" = "http://localhost:${toString floodPort}";
  };

  services.rtorrent = {
    enable = true;
    downloadDir = "/mnt/data/torrents";
    configText = ''
      system.umask.set = 0002
    '';
  };

  users.users.${config.services.rtorrent.user} = {
    home = "/var/lib/rtorrent";
    createHome = true;
  };

  systemd.services.flood = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.flood}/bin/flood --port=${toString floodPort} --rundir=${config.services.rtorrent.dataDir} --rtsocket=${config.services.rtorrent.rpcSocket}";
      User = config.services.rtorrent.user;
      Group = config.services.rtorrent.group;
      Restart = "on-failure";
    };
  };
}
