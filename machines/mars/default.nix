# Raspberry Pi 5B, 8GB
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
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
  };

  virtualisation.docker.enable = true;

  boot.supportedFilesystems = [
    "btrfs"
    "vfat"
    "bcachefs"
  ];

  raspberry-pi-nix = {
    board = "bcm2712";
    # Needed for bcachefs
    kernel-version = "v6_12_11";
    # We're not using a camera, no point
    libcamera-overlay.enable = false;
    firmware-partition-label = "BOOT";
  };

  networking.firewall.extraCommands = ''
    # Huawei AP keeps spamming requests to dmesg, stop logging them.
    iptables \
      --insert nixos-fw-log-refuse 1 \
      --source 192.168.1.65 \
      --protocol tcp \
      --dport 40000 \
      --jump nixos-fw-refuse
  '';

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
    "/mnt" = {
      device = "/dev/disk/by-uuid/219c1fb6-beeb-450a-a3c2-59ab6fb43b84";
      options = [
        "noatime"
        "nofail"
      ];
      fsType = "bcachefs";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      # 8GiB
      size = 8 * 1024;
    }
  ];

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

  users.users.pta2002.extraGroups = [
    "docker"
  ];

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

  # Stuff for cloudflared
  age.secrets.marstunnel = {
    file = ../../secrets/marstunnel.json.age;
    owner = config.services.cloudflared.user;
  };
}
