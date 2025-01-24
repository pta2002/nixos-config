# Raspberry Pi 5B, 8GB
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/home-assistant.nix
    ../modules/transmission.nix
    ../modules/qbittorrent.nix
    ../modules/filespi.nix
    ../modules/plex.nix
    ../modules/sonarr.nix
    ../modules/matterbridge.nix
    # ../modules/samba.nix
    # ../modules/grafana.nix
    # ../modules/quassel.nix
    # ../modules/jellyfin.nix
    # ../modules/rpi-kernel.nix
  ];

  services.qbittorrent.enable = true;
  services.qbittorrent.webui-port = 8844;

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

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  networking.hostName = "mars";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
  };

  environment.shells = with pkgs; [ bash fish ];
  programs.fish.enable = true;
  users.users.pta2002 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "argoweb" "docker" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ../ssh-keys.nix;
    password = "";
  };

  users.users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;

  security.polkit = {
    enable = true;

    extraConfig = /* js */ ''
      // Users in the wheel group have essentially 'nopasswd' set.
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });

      // Wheel group is used for admin.
      polkit.addAdminRule(function(action, subject) {
        return ["unix-group:wheel"];
      });
    '';
  };

  security.sudo.extraRules = [{
    users = [ "pta2002" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    nh
  ];

  nix.settings.trusted-users = [ "root" "pta2002" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.cloudflared = {
    enable = true;
    tunnels.mars.credentialsFile = config.age.secrets.marstunnel.path;
    tunnels.mars.default = "http_status:404";
  };

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  # Stuff for argo
  age.secrets.marstunnel = {
    file = ../secrets/marstunnel.json.age;
    owner = config.services.cloudflared.user;
  };
}

