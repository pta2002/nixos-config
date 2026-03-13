{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/4ce4ecc2-666f-41b5-a952-a8466a309cd3";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/8F94-DEC6";
      fsType = "vfat";
    };
    "/mnt" = {
      device = "/dev/sda4";
      fsType = "btrfs";
      options = [ "noatime" ];
    };
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
  ];

  boot.initrd.kernelModules = [ "nvme" ];
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
}
