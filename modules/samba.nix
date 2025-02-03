{ pkgs, ... }:
{
  services.samba-wsdd.enable = true;
  services.samba-wsdd.openFirewall = true;


  services.samba = {
    enable = true;
    package = pkgs.sambaFull;

    settings.data = {
      path = "/mnt/data";
      writable = "true";
      "force create mode" = "0660";
      "force directory mode" = "2770";
      "directory mask" = "0775";
      "force group" = "data";
      "guest ok" = "no";
      "read only" = "no";
    };

    settings.global = {
      workgroup = "mars";
      "netbios name" = "mars";
      security = "user";
      "hosts allow" = [ "100.0.0.0/8" "fd7a:115c:a1e0::/48" "127.0.0.1" "localhost" ];
      "hosts deny" = [ "0.0.0.0/0" ];
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "unix password sync" = "yes";
      "server role" = "standalone server";
    };

    openFirewall = true;
  };

  networking.firewall.allowPing = true;
}
