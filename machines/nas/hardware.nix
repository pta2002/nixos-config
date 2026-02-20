{
  pkgs,
  lib,
  config,
  ...
}:
{
  hardware.facter.reportPath = ./facter.json;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  # use the latest Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.kernelModules = [
    # Rockchip modules
    "rockchip_rga"
    "rockchip_saradc"
    "rockchip_thermal"
    "rockchipdrm"

    # GPU/Display modules
    "analogix_dp"
    "cec"
    "drm"
    "drm_kms_helper"
    "dw_hdmi"
    "dw_mipi_dsi"
    "gpu_sched"
    "panel_edp"
    "panel_simple"
    "panfrost"
    "pwm_bl"

    # USB / Type-C related modules
    "fusb302"
    "tcpm"
    "typec"

    # Misc. modules
    "cw2015_battery"
    "gpio_charger"
    "rtc_rk808"
  ];

  # kernelParams copy from Armbian's /boot/armbianEnv.txt & /boot/boot.cmd
  boot.kernelParams = [
    "rootwait"

    "earlycon" # enable early console, so we can see the boot messages via serial port / HDMI
    "consoleblank=0" # disable console blanking(screen saver)
    "console=ttyS2,1500000" # serial port
    "console=tty1" # HDMI
    # "dtb=/${config.hardware.deviceTree.name}"
  ];

  boot.supportedFilesystems = [
    "btrfs"
    "bcachefs"
  ];

  fileSystems."/mnt" = {
    device = "/dev/disk/by-uuid/c7994232-0665-4d6a-9933-80d444654af4";
    options = [
      "noatime"
      "nofail"
    ];
    fsType = "bcachefs";
  };

  # Generate device tree into EFI partition
  # boot.loader.systemd-boot.extraFiles.${config.hardware.deviceTree.name} =
  #   "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
  # hardware.deviceTree.enable = true;
  # hardware.deviceTree.name = "rockchip/rk3588-rock-5-itx.dtb";
  # hardware.deviceTree.filter = "*-rock-5-itx*.dtb";

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "nas";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    htop
  ];
  system.stateVersion = "26.05";
}
