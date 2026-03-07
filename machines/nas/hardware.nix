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
    device = "/dev/disk/by-uuid/219c1fb6-beeb-450a-a3c2-59ab6fb43b84";
    options = [
      "noatime"
      "nofail"
      "version_upgrade=compatible"
    ];
    fsType = "bcachefs";
  };

  # Generate device tree into EFI partition
  boot.loader.systemd-boot.extraFiles.${config.hardware.deviceTree.name} =
    "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";

  hardware.deviceTree = {
    enable = true;
    name = "rockchip/rk3588-rock-5-itx.dtb";
    filter = "*-rock-5-itx*.dtb";

    overlays = [
      # This gets the HDMI receiver working on the Rock 5 ITX.
      # Unfortunately the receiver wasn't wired in correctly upstream!
      # TODO: https://lore.kernel.org/linux-devicetree/20260304-radxa-r5-itx-hdmirx-v1-1-f77bf1f7ce03@pta2002.com/
      {
        name = "hdmirx";
        dtsText = /* dts */ ''
          #include <dt-bindings/gpio/gpio.h>
          #include <dt-bindings/pinctrl/rockchip.h>

          /dts-v1/;
          /plugin/;

          / {
            compatible = "radxa,rock-5-itx", "rockchip,rk3588";
          };

          /* &pinctrl {
            hdmirx {
              hdmirx_hpd: hdmirx-5v-detection {
                rockchip,pins = <1 RK_PC6 RK_FUNC_GPIO &pcfg_pull_none>;
              };
            };
          }; */

          &hdmi_receiver_cma {
            status = "okay";
          };

          &hdmi_receiver {
            pinctrl-0 = <&hdmim1_rx_cec &hdmim1_rx_hpdin &hdmim1_rx_scl &hdmim1_rx_sda &hdmirx_det>;
            pinctrl-names = "default";

            hpd-gpios = <&gpio1 RK_PC6 GPIO_ACTIVE_LOW>;
            status = "okay";
          };
        '';
      }
    ];
  };

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
