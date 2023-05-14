# Common file for _all_ systems.
{ config, pkgs, inputs, ... }:
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
  environment.shells = with pkgs; [ bash fish ];

  # Misc.
  documentation.dev.enable = true;

  # User
  users.users.pta2002 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "audio" "video" "networkmanager" "wireshark" "adbusers" "libvirtd" ];
    openssh.authorizedKeys.keys = import ./ssh-keys.nix;
  };

  # Security
  security.sudo.extraConfig = ''
    Defaults pwfeedback
  '';

  # Nix
  nixpkgs.config.allowUnfree = true;
  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      n.flake = inputs.nixpkgs;
      stable.flake = inputs.nixpkgs-stable;
      s.flake = inputs.nixpkgs-stable;
    };
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://cuda-maintainers.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      ];

      trusted-users = [ "root" "pta2002" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  systemd.extraConfig = "DefaultLimitNOFILE=524288";

  system.stateVersion = "21.11";
}
