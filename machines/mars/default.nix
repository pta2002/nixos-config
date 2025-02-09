# Raspberry Pi 5B, 8GB
{ config, pkgs, lib, ... }:
{
  imports = [
    ../../modules/home-assistant.nix
    ../../modules/filespi.nix
    ../../modules/matterbridge.nix
    ../../modules/proxy.nix
    ../../modules/thelounge.nix
    ../../modules/samba.nix
  ];

  proxy.enable = true;
  proxy.domain = "m.pta2002.com";
  proxy.environmentFile = config.age.secrets.caddy-mars.path;
  proxy.ipv4 = "100.126.178.45";
  proxy.ipv6 = "fd7a:115c:a1e0::2501:b22d";

  age.secrets.caddy-mars = {
    file = ../../secrets/caddy-mars.age;
    owner = config.services.caddy.user;
  };

  virtualisation.docker.enable = true;

  boot.supportedFilesystems = [ "btrfs" "vfat" ];
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = true;

  # The only difference between the rpi4 and the rpi5 kernels is the page size
  # (4K vs 16K). However, the rpi5 kernel isn't built by Hydra so it means a 2+
  # hour compile time whenever there's an update. The performance difference
  # isn't that great, so honestly it's best to just use the kernel for the pi
  # 4.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NixOS";
      options = [
        "compress=zstd"
        "subvol=root"
      ];
      fsType = "btrfs";
    };
    "/home" = {
      device = "/dev/disk/by-label/NixOS";
      options = [
        "compress=zstd"
        "subvol=home"
      ];
      fsType = "btrfs";
    };
    "/nix" = {
      device = "/dev/disk/by-label/NixOS";
      options = [
        "compress=zstd"
        "subvol=nix"
        "noatime"
      ];
      fsType = "btrfs";
    };
    "/mnt/data" = {
      device = "/dev/disk/by-id/ata-ST500LT012-1DG142_WBYK8FNL";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=data"
        "device=/dev/disk/by-id/ata-WDC_WD10EZEX-75WN4A0_WD-WCC6Y7SY7KJU"
      ];
      fsType = "btrfs";
    };
  };

  swapDevices = [{
    device = "/swapfile";
    # 8GiB
    size = 8 * 1024;
  }];

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = "ondemand";

  networking.hostName = "mars";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
  };

  users.users.pta2002.extraGroups = [ "argoweb" "docker" ];

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    nh
  ];

  services.cloudflared = {
    enable = true;
    tunnels.mars.credentialsFile = config.age.secrets.marstunnel.path;
    tunnels.mars.default = "http_status:404";
  };

  services.tailscale.enable = true;

  system.stateVersion = "24.11";

  # Stuff for argo
  age.secrets.marstunnel = {
    file = ../../secrets/marstunnel.json.age;
    owner = config.services.cloudflared.user;
  };
}

