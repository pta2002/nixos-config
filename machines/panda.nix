{ pkgs, ... }:
{
  imports = [
    ../disk-config.nix
  ];

  networking.hostName = "panda";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
  };

  environment.shells = with pkgs; [ bash fish ];
  programs.fish.enable = true;
  users.users.pta2002 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ../ssh-keys.nix;
    password = "";
  };

  users.users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;
  security.polkit = {
    enable = true;

    extraConfig = /* js */ ''
      // Users in the wheel group have essentially 'nopasswd' set.
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });

      // Wheel group is used for admin.
      polkit.addAdminRule(function(action, subject) {
        return ["unix-group:wheel"];
      });
    '';
  };

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
    nh
  ];

  nix.settings.trusted-users = [ "root" "pta2002" ];

  boot.supportedFilesystems = [ "btrfs" "bcachefs" "vfat" ];
  boot.loader.systemd-boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;
}
