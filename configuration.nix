# Common file for _all_ systems.
{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Networking
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  services.tailscale.enable = true;

  # Time
  time.timeZone = "Europe/Lisbon";
  time.hardwareClockInLocalTime = true;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  # Shells
  programs.fish.enable = true;
  environment.shells = with pkgs; [
    bash
    fish
  ];

  # Misc.
  documentation.dev.enable = true;

  # User
  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
      "audio"
      "video"
      "networkmanager"
      "wireshark"
      "adbusers"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = import ./ssh-keys.nix lib;
  };

  # Security
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  environment.systemPackages = [ pkgs.blender ];

  # Nix
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.permittedInsecurePackages = [ "zotero-6.0.27" ];
  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      n.flake = inputs.nixpkgs;
    };
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://cuda-maintainers.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];

      trusted-users = [
        "root"
        "pta2002"
      ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  systemd.extraConfig = "DefaultLimitNOFILE=524288";

  system.stateVersion = "21.11";
}
