# Access the NFS shares exposed by the NFS server.
{ lib, config, ... }:
{
  config = lib.mkMerge [
    {
      # I don't want to have to deal with kerberos/idmapd, NFS is messy enough as is. At least this way things should "work" for the most part.
      users.groups.data = { gid = 988; };
      users.users.pta2002.extraGroups = [ "data" ];

      networking.domain = "pta2002.com";
    }
    (lib.mkIf (!config.common.role.data-host.enabled) {
      services.rpcbind.enable = true;
      fileSystems."/srv" = {
        fsType = "nfs";
        device = "${config.common.role.data-host.name}:/data";
        options = [ "x-systemd.automount" "noauto" "noatime" ];
      };
    })
  ];
}
