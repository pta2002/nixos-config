{ pkgs, config, lib, ... }:
let
  version = "6.9.1";
  rpi-kernel = pkgs.linux_rpi4.override {
    argsOverride = {
      src = pkgs.fetchFromGitHub {
        owner = "raspberrypi";
        repo = "linux";
        rev = "4ecd92372867652f9d73bca340c1e3e12559750f";
        sha256 = "sha256-SpIIvAN87BYlz4la2PPtI91ysEqSbGVH8xjHuPf0qIo=";
      };

      # This is the value for the Pi 5 kernel
      defconfig = "bcm2712_defconfig";

      inherit version;
      modDirVersion = version;

      structuredExtraConfig = with lib.kernel; {
        KUNIT = no;
        GPIO_PWM = no;
      };

      kernelPatches = [];
    };
  };
in
{
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor rpi-kernel);
}
