# This is the NixOS config file!
{ config, pkgs, inputs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";
  time.hardwareClockInLocalTime = true;

  networking.useDHCP = false;

  services.tailscale.enable = true;

  networking.firewall.enable = false;

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = ./wallpaper.jpg;
    greeters.gtk = {
      enable = false;
      theme.name = "Adwaita-Dark";
    };

    greeters.slick = {
      enable = true;
      theme.name = "Adwaita Dark";
    };
  };
  services.xserver.displayManager.session = [{
    manage = "desktop";
    name = "xsession";
    start = ''exec $HOME/.xsession'';
  }];
  services.upower.enable = true;
  services.xserver.windowManager.bspwm.enable = true;

  boot.plymouth = {
    enable = true;
  };

  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
  services.xserver.wacom.enable = true;

  services.xserver.layout = "pt";

  services.fstrim.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };

  services.udisks2.enable = true;
  services.gnome.gnome-keyring.enable = true;

  hardware.pulseaudio.enable = false;
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # config.pipewire = {
    #   "context.properties" = {
    #     "link.max-buffers" = 16;
    #     "log.level" = 2;
    #     "default.clock.rate" = 48000;
    #     "default.clock.quantum" = 32;
    #     "default.clock.min-quantum" = 32;
    #     "default.clock.max-quantum" = 32;
    #     "core.daemon" = true;
    #     "core.name" = "pipewire-0";
    #   };
    #   "context.modules" = [
    #     {
    #       name = "libpipewire-module-rtkit";
    #       args = {
    #         "nice.level" = -15;
    #         "rt.prio" = 88;
    #         "rt.time.soft" = 200000;
    #         "rt.time.hard" = 200000;
    #       };
    #       flags = [ "ifexists" "nofail" ];
    #     }
    #     { name = "libpipewire-module-protocol-native"; }
    #     { name = "libpipewire-module-profiler"; }
    #     { name = "libpipewire-module-metadata"; }
    #     { name = "libpipewire-module-spa-device-factory"; }
    #     { name = "libpipewire-module-spa-node-factory"; }
    #     { name = "libpipewire-module-client-node"; }
    #     { name = "libpipewire-module-client-device"; }
    #     {
    #       name = "libpipewire-module-portal";
    #       flags = [ "ifexists" "nofail" ];
    #     }
    #     {
    #       name = "libpipewire-module-access";
    #       args = { };
    #     }
    #     { name = "libpipewire-module-adapter"; }
    #     { name = "libpipewire-module-link-factory"; }
    #     { name = "libpipewire-module-session-manager"; }
    #   ];
    # };
  };

  programs.wireshark.enable = true;
  # programs.adb.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  # Required for virt-manager
  programs.dconf.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.shells = with pkgs; [ bash fish ];

  documentation.dev.enable = true;

  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "audio" "video" "networkmanager" "wireshark" "adbusers" "libvirtd" ];
  };

  environment.etc.jdk.source = pkgs.jdk17;
  environment.etc.jdk11.source = pkgs.jdk11;
  environment.etc.jdk8.source = pkgs.jdk8;

  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [ "root" "pta2002" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  system.stateVersion = "21.11";

  nixpkgs.config.permittedInsecurePackages = [
    "electron-13.6.9"
  ];

  nixpkgs.overlays = [
    (import ./overlays/sxiv)
    (import ./overlays/my-scripts pkgs)
  ];

  # For vagrant
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "pta2002" ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}
