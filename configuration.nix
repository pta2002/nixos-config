# This is the NixOS config file!
{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";

  networking.useDHCP = false;

  services.tailscale.enable = true;

  networking.firewall.enable = false;

  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.windowManager.awesome.enable = true;
  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };
  services.xserver.wacom.enable = true;

  services.xserver.layout = "pt";

  services.fstrim.enable = true;

  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.wireshark.enable = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;

  environment.shells = with pkgs; [ bash fish ];

  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "audio" "video" "networkmanager" "wireshark" "adbusers" ];
  };

  environment.etc.jdk.source = pkgs.jdk17;

  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [ "root" "pta2002" ];
  # nix.package = pkgs.nix_2_4;
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
}
