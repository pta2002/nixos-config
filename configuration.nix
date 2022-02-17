# This is the NixOS config file!
{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "mercury";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Lisbon";

  networking.useDHCP = false;
  networking.interfaces.wlo1.useDHCP = true;

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

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.prime = {
    offload.enable = true;

    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:02:00:0";
  };

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
  environment.systemPackages = [ nvidia-offload ];

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
}
