{ pkgs, lib, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/61bc8cb0-f704-42da-bdbe-8002ec9c39c9";
      fsType = "btrfs";
      options = [ "subvol=root" "compress" "autodefrag" ];
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/61bc8cb0-f704-42da-bdbe-8002ec9c39c9";
      fsType = "btrfs";
      options = [ "subvol=home" "compress" "autodefrag" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/E209-5782";
      fsType = "vfat";
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "hydrogen";
  networking.interfaces.enp3s0.useDHCP = true;

  musnix.enable = true;
  # musnix.kernel.optimize = true;
  # musnix.kernel.realtime = true;
}
