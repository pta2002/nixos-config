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
      "hosts allow" = [
        "192.168.0.0/16"
        "100.0.0.0/8"
        "fd7a:115c:a1e0::/48"
        "127.0.0.1"
        "localhost"
      ];
      "hosts deny" = [ "0.0.0.0/0" ];
      "guest account" = "nobody";
      "map to guest" = "bad user";
      "unix password sync" = "yes";
      "server role" = "standalone server";

      # Mac extensions require SMB2/3
      "min protocol" = "SMB2";
      # Extended attributes
      "ea spport" = "yes";
      "vfs objects" ="fruit streams_xattr";

      # Settings for TimeMachine
      # https://wiki.samba.org/index.php/Configure_Samba_to_Work_Better_with_Mac_OS_X
      "fruit:metadata" = "stream";
      "fruit:model" = "MacPro";
      "fruit:advertise_fullsync" = true;
      "fruit:appl" = "yes";
      "fruit:veto_appledouble" ="no";
      "fruit:zero_file_id" = "yes";
      "fruit:wipe_intentionally_left_blank_rfork" = "yes";
      "fruit:delete_empty_adfiles" = "yes";
      "fruit:posix_rename" = "yes";
    };

    settings."TimeMachine Home" = {
      path = "/mnt/data/timemachine/%U";
      "valid users" = "%U";
      "writable" = "yes";
      "durable handles" = "yes";
      "kernel oplocks" = "no";
      "kernel share modes" = "no";
      "posix locking" = "no";
      "vfs objects" = "catia fruit streams_xattr";
      "ea support"=  "yes";
      "browseable" = "yes";
      "read only" = "No";
      "inherit acls" = "yes";
      "fruit:time machine" = "yes";
    };

    openFirewall = true;
  };

  networking.firewall.allowPing = true;
}
