{ pkgs, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;

  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano";
    carrierBoard = "devkit";
    super = true;

    # TODO: This does not yet work on k3s. I will need to figure out why.
    container-toolkit.enable = true;
  };

  services.nomad.settings.client.node_pool = "nvidia";

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
