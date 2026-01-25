{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.boot.loader.rpi-5;
in
{
  options = {
    boot.loader.rpi-5 = {
      enable = lib.mkEnableOption "Raspberry 5 bootloader";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub.enable = lib.mkDefault false;

    system = {
      build.installBootLoader = pkgs.substituteAll {
        src = ./install-rpi.py;
        isExecutable = true;
        inherit (pkgs) python3;
      };
      boot.loader.id = "rpi5";

      boot.loader.kernelFile = pkgs.stdenv.hostPlatform.linux-kernel.target;
    };

    boot.bootspec.enable = true;
    boot.bootspec.extensions = {
      "com.pta2002.rpi5" = {
        # TODO: This should be a parameter
        "firmwarePartition" = "/boot/firmware/";
        # TODO: We can get the dtb and overlays files from the kernel build.
        # What's left is the firmware files - bootcode.bin, fixup.dat and start.elf. Those are in the RPi firmware repository.
        "firmwarePath" = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
        # TODO: This should be handled by me
        "configPath" = "${config.hardware.raspberry-pi.config-output}";
      };
    };

    boot.loader.initScript.enable = lib.mkForce false;
  };
}
