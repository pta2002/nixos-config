{ pkgs, lib, ... }:
{
  imports = [
    ../modules/desktop.nix
    ../modules/musnix.nix
  ];

  networking.hostId = "fa73900d";

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.loader.refind.extraConfig = ''
    resolution 3440 1440
  '';

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "vfio-pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "i2c-dev" "snd-seq" "snd-rawmidi" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "iommu=pt"
    "intel_iommu=on"
    "vfio-pci.ids=8086:0412,8086:0c0c"
    "preempt=full"
  ];
  hardware.i2c.enable = true;
  services.udev.packages = [ pkgs.openrgb ];

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
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.mesa.drivers ];
  };
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  networking.hostName = "hydrogen";
  networking.interfaces.enp3s0.useDHCP = true;

  musnix.enable = true;
  security.rtkit.enable = true;
  # environment.etc = {
  #   "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
  #     context.properties = {
  #       default.clock.rate = 48000;
  #       default.clock.quantum = 32;
  #       default.clock.min-quantum = 32;
  #       default.clock.max-quantum = 32;
  #     }
  #   '';
  # };

  environment.sessionVariables = {
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
