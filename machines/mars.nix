# Raspberry Pi 5B, 8GB
{ config, pkgs, lib, ... }:
{
  imports = [
    ../modules/home-assistant.nix
    ../modules/samba.nix
    ../modules/transmission.nix
    # ../modules/filespi.nix
    ../modules/plex.nix
    ../modules/sonarr.nix
    # ../modules/grafana.nix
    # ../modules/quassel.nix
    # ../modules/jellyfin.nix
    # ../modules/rpi-kernel.nix
  ];

  # TODO: This is another raspberry-pi-nix quirk. It assumes an SD card which
  # would have this kind of partition ID, and therefore this gets set on the
  # kernel cmdline to be the root partition to boot from.
  sdImage.firmwarePartitionID = "3c7dbdf7";

  boot.supportedFilesystems = [ "btrfs" "vfat" ];

  # fileSystems."/" = lib.mkForce {
  #   device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot/firmware" = lib.mkForce {
  #   device = "/dev/disk/by-label/FIRMWARE";
  #   fsType = "vfat";
  # };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-id/ata-ST500LT012-1DG142_WBYK8FNL";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=data"
      "device=/dev/disk/by-id/ata-WDC_WD10EZEX-75WN4A0_WD-WCC6Y7SY7KJU"
    ];
    fsType = "btrfs";
  };

  # disko.devices = {
  #   disk.sda = {
  #     type = "disk";
  #     device = "/dev/disk/by-id/ata-ST500LT012-1DG142_WBYK8FNL";
  #     content = {
  #       type = "gpt";
  #       partitions.data = {
  #         size = "100%";
  #         content = {
  #           type = "btrfs";
  #           extraArgs = ["-f"];
  #           mountpoint = "/mnt/data2";
  #           mountOptions = [ "compress=zstd" "noatime" ];
  #         };
  #       };
  #     };
  #   };
  # };

  hardware = {
    raspberry-pi = {
      config = {};
    };
  };

  # raspberry-pi-nix.kernel-version = "v6_10_0-rc5";

  # boot.loader.rpi-5.enable = true;
  # raspberry-pi-nix.firmware-migration-service.enable = false;

  raspberry-pi-nix = {
    board = "bcm2712";
    libcamera-overlay.enable = lib.mkForce false;
    uboot.enable = false;
  };

  # For now, mounting multi-device bcachefs on fstab does not work :c
  # Just use a systemd service :shrug:
  # systemd.services."data-volume" = {
  #   description = "Mount BcacheFS storage";
  #   requires = [ "-.mount" "dev-sda.device" "dev-sdb.device" ];
  #   after = [ "-.mount" "dev-sda.device" "dev-sdb.device" ];
  #
  #   wantedBy = [ "local-fs.target" ];
  #
  #   serviceConfig.Type = "oneshot";
  #   # serviceConfig.ExecStart = "${pkgs.bcachefs-tools}/bin/bcachefs mount -v UUID=ae0fadc6-5110-4a67-ac19-b89c117e36e3 /mnt/data";
  #   serviceConfig.ExecStart = "${pkgs.bcachefs-tools}/bin/bcachefs mount -v /dev/sda:/dev/sdb /mnt/data";
  # };

  swapDevices = [ ];

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = "ondemand";

  systemd.services.NetworkManager-wait-online.enable = false;

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  # boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  # boot.loader.generic-extlinux-compatible.enable = true;
  # boot.tmp.useTmpfs = true;
  # boot.kernelParams = [ "8250.nr_uarts=1" "cma=512M" ];
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

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;

  # Stuff for argo
  age.secrets.marstunnel = {
    file = ../secrets/marstunnel.json.age;
    owner = config.services.cloudflared.user;
  };
}

