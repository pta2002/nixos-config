{ pkgs, lib, ... }:
{
  networking.hostId = "fa73900d";

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "vfio-pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "iommu=pt"
    "intel_iommu=on"
    "vfio-pci.ids=8086:0412,8086:0c0c"
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/1e5ec187-b64e-4a3a-a058-259272aa54c5";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/3D21-52D1";
      fsType = "vfat";
    };

  fileSystems."/mnt/drive0" = {
    device = "/dev/sr0";
    fsType = "auto";
    options = [
      "ro"
      "user"
      "noauto"
      "unhide"
    ];
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  networking.hostName = "hydrogen";
  networking.interfaces.enp3s0.useDHCP = true;

  musnix.enable = true;
  # musnix.kernel.optimize = true;
  # musnix.kernel.realtime = true;

  # Fixing the damn keyboard...
  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText "xkb-layout" ''
  #     keycode 94 = backslash bar backslash bar notsign notsign notsign
  #     keycode 49 = less greater less greater backslash backslash backslash
  #   ''}"
  # '';
}
