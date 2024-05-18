# Raspberry Pi 5B, 8GB
{ config, pkgs, lib, ... }:
{
  imports = [
    # ../modules/home-assistant.nix
    # ../modules/samba.nix
    # ../modules/flood.nix
    # ../modules/filespi.nix
    # ../modules/plex.nix
    # ../modules/sonarr.nix
    # ../modules/argoweb.nix
    # ../modules/grafana.nix
    # ../modules/quassel.nix
    # ../modules/jellyfin.nix
  ];

  # services.argoWeb.enable = true;

  # boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ ];
  # boot.extraModulePackages = [ ];
  # boot.supportedFilesystems = [ "bcachefs" ];

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
  #   fsType = "ext4";
  # };

  hardware = {
    # bluetooth.enable = true;
    raspberry-pi = {
      config = { };
    };
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
  ];
  # virtualisation.docker.enable = true;

  nix.settings.trusted-users = [ "root" "pta2002" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  # Stuff for argo
  # age.secrets.cloudflared = {
  #   file = ../secrets/pietunnel.json.age;
  #   owner = "argoweb";
  # };

  # age.secrets.cert = {
  #   file = ../secrets/cert.pem.age;
  #   owner = "argoweb";
  # };
  #
  # services.argoWeb.tunnel = "pietunnel";
}

