# Config file for desktop systems
{ pkgs, pkgs-nocuda, ... }: {
  imports = [
    ./ssh.nix
    ./wayland.nix
    # ./refind.nix
  ];

  # CPU
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.plymouth.enable = true;

  boot.loader.systemd-boot.enable = true;

  # boot.loader.refind =
  #   let
  #     theme = pkgs.stdenv.mkDerivation {
  #       name = "rEFInd-minimal-themes";
  #       version = "master";
  #
  #       src = pkgs.fetchFromGitHub {
  #         owner = "quantrancse";
  #         repo = "rEFInd-minimal-themes";
  #         rev = "ba0742e235b33d5f13e6c7e2b6a46fe7ba1634aa";
  #         hash = "sha256-A2rsWyCldo1TjySVKs4PO5PyCM/adn+LPp3lXyNpZoA=";
  #       };
  #
  #       patches = [ ../modules/refind-theme.patch ];
  #
  #       dontConfigure = true;
  #       dontBuild = true;
  #       dontFixup = true;
  #
  #       installPhase = ''
  #         mkdir -p $out
  #         cp -r * $out
  #       '';
  #     };
  #   in
  #   {
  #     enable = true;
  #     extraConfig = ''
  #       include themes/rEFInd-minimal-dark/theme.conf
  #       scanfor external,manual
  #     '';
  #     extraThemes = [ theme ];
  #   };

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

  # Video + keyboard
  services.xserver = {
    enable = true;
    xkb.layout = "pt";
  };

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Audio
  security.rtkit.enable = true;
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

  i18n.inputMethod= {
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      uniemoji
      table
      anthy
    ];
  };
}
