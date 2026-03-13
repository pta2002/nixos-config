{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partuuid/4ce4ecc2-666f-41b5-a952-a8466a309cd3";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/dd0aa973-7f9c-4339-9f9e-fcb15a482ea7";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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
