# Access the NFS shares exposed by the NFS server.
{ lib, config, ... }:
{
  config = lib.mkMerge [
    {
      # I don't want to have to deal with kerberos/idmapd, NFS is messy enough as is. At least this way things should "work" for the most part.
      users.groups.data = {
        gid = 988;
      };
      users.users.pta2002.extraGroups = [ "data" ];

      networking.domain = "pta2002.com";
    }
    (lib.mkIf (!config.common.role.data-host.enabled) {
      # If we're not the data host, we want to mount it via NFS
      services.rpcbind.enable = true;
      fileSystems."/srv/media" = {
        fsType = "nfs";
        device = "${config.common.role.data-host.name}:/data";
        options = [
          "x-systemd.automount"
          "nofail"
          "noatime"
        ];
      };
    })
    (lib.mkIf (config.common.role.data-host.enabled) {
      # If we ARE the data host, we want to use a bind mount
      fileSystems."/srv/media" = {
        depends = [ "/mnt" ];
        device = "/mnt/data";
        fsType = "none";
        options = [
          "bind"
          "noatime"
          "nofail"
        ];
      };
    })
  ];
}
