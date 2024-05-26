{ pkgs, config, lib, ... }:
let
  version = "6.9.1";
  rpi-kernel = pkgs.linuxManualConfig {
      src = pkgs.fetchFromGitHub { owner = "raspberrypi";
        repo = "linux";
        rev = "4ecd92372867652f9d73bca340c1e3e12559750f";
        sha256 = "sha256-SpIIvAN87BYlz4la2PPtI91ysEqSbGVH8xjHuPf0qIo=";
      };
      inherit version;
      modDirVersion = "${version}";
      configfile = ./kernel.config;
      allowImportFromDerivation = true;
  };
  cfg = config.boot.loader.rpi-5;
in
{
  options = {
    boot.loader.rpi-5 = {
      enable = lib.mkEnableOption ''Raspberry 5 bootloader'';
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
        "firmwarePath" = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
        # TODO: This should be handled by me
        "configPath" = "${config.hardware.raspberry-pi.config-output}";
      };
    };

    boot.loader.initScript.enable = lib.mkForce false;
    boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor rpi-kernel);
  };
}
