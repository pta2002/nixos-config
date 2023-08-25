# Config file for desktop systems
{ pkgs, pkgs-nocuda, ... }: {
  imports = [
    ./ssh.nix
    ./wayland.nix
  ];

  # CPU
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" "zfs" ];
  boot.plymouth.enable = true;

  # Networking
  networking.firewall.enable = false;

  # Misc. hardware
  hardware.bluetooth.enable = true;
  services.fstrim.enable = true;

  services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

  services.xserver.desktopManager.gnome.enable = true;

  hardware.opentabletdriver.enable = true;

  # Video
  services.xserver = {
    enable = true;
    layout = "pt";
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };

  # Audio
  sound.enable = true;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Power management
  services.upower.enable = true;

  # Printers
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  # Programs
  programs.wireshark.enable = true;
  programs.adb.enable = true;
  programs.dconf.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
