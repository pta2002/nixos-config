{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  networking.hostName = "mercury";
  
  networking.interfaces.wlo1.useDHCP = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.prime = {
    offload.enable = true;

    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:02:00:0";
  };

  environment.systemPackages = [ nvidia-offload ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ba866b4c-d78d-4ade-a9b8-5064b5faa3e6";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3231529d-a4e6-4976-a325-c7c5ffc677dc"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
