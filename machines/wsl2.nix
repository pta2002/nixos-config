{ lib, pkgs, config, modulesPath, nixos-wsl, ... }:

with lib;
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = "pta2002";
    startMenuLaunchers = true;
    nativeSystemd = true;
    wslConf.automount.root = "/mnt";

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  environment.systemPackages = with pkgs; [
    github-cli
    wget
    nodejs
    ripgrep
  ];

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.trusted-users = [ "pta2002" ];

  system.stateVersion = "22.05";

  programs.fish.enable = true;
  environment.shells = with pkgs; [ bash fish ];
  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };

  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  services.tailscale.enable = true;

  home-manager.users.pta2002 = {
    programs.direnv.enable = true;
  };
}
