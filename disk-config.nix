# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-id/mmc-CUTA42_0x8210ba01";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            end = "-0";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
