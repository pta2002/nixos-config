{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-WD_Blue_SN5000_1TB_2513E2403458";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "ESP";
          start = "1M";
          end = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0022" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            subvolumes = {
              "/".mountpoint = "/";
              "/home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
