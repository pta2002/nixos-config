{ ... }:
{
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];

  services.samba = {
    enable = true;

    settings.global = {
      workgroup = "WORKGROUP";
      "server string" = "Mars";
      "netbios name" = "mars";
      "security" = "user";
      "hosts allow" = [ "100.0.0.0/8" "127.0.0.1" "192.168.0.0/16" "localhost" ];
      "hosts deny" = [ "0.0.0.0/0" ];
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "acl allow execute always" = "True";
    };

    settings.torrents = {
      path = "/mnt/data/torrents";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "no";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "transmission";
      "force group" = "transmission";
    };

    openFirewall = true;
  };

  networking.firewall.allowPing = true;
}
