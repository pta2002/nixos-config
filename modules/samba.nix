{ pkgs, lib, ... }:
{
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Pie
      netbios name = pie
      security = user
      hosts allow = 100.0.0.0/8 127.0.0.1 192.168.0.0/16 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      acl allow execute always = True
    '';
    shares = {
      torrents = {
        path = "/mnt/data/torrents";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rtorrent";
        "force group" = "rtorrent";
      };

      files = {
        path = "/mnt/data/files";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pta2002";
        "force group" = "users";
      };
    };
    openFirewall = true;
  };

  networking.firewall.allowPing = true;
}
