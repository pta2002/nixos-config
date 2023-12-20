{ pkgs, lib, ... }:
{
  imports = [
    ../modules/desktop.nix
    ../modules/musnix.nix
    ../modules/refind.nix
  ];

  networking.hostId = "fa73900d";

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  boot.loader.refind =
    let
      theme = pkgs.stdenv.mkDerivation {
        name = "rEFInd-minimal-themes";
        version = "master";

        src = pkgs.fetchFromGitHub {
          owner = "quantrancse";
          repo = "rEFInd-minimal-themes";
          rev = "ba0742e235b33d5f13e6c7e2b6a46fe7ba1634aa";
          hash = "sha256-A2rsWyCldo1TjySVKs4PO5PyCM/adn+LPp3lXyNpZoA=";
        };

        patches = [ ../modules/refind-theme.patch ];

        dontConfigure = true;
        dontBuild = true;
        dontFixup = true;

        installPhase = ''
          mkdir -p $out
          cp -r * $out
        '';
      };
    in
    {
      enable = true;
      extraConfig = ''
        resolution 1920 1080
        include themes/rEFInd-minimal-dark/theme.conf
        scanfor external,manual
      '';
      extraThemes = [ theme ];
    };
  boot.loader.systemd-boot.enable = lib.mkForce false;

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
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
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

  # Fixing the damn keyboard...
  # services.xserver.displayManager.sessionCommands = ''
  #   ${pkgs.xorg.xmodmap}/bin/xmodmap "${pkgs.writeText "xkb-layout" ''
  #     keycode 94 = backslash bar backslash bar notsign notsign notsign
  #     keycode 49 = less greater less greater backslash backslash backslash
  #   ''}"
  # '';

  environment.sessionVariables = {
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
