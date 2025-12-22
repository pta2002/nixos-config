{ pkgs, lib, ... }:
{
  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano";
    carrierBoard = "devkit";
    super = true;
    configureCuda = false;
  };

  boot.supportedFilesystems = [
    "btrfs"
    "vfat"
  ];
  boot.loader.systemd-boot.enable = true;

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "jetson";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    git
    htop
  ];
  system.stateVersion = "25.05";
}
