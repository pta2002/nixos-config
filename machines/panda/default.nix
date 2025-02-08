{ pkgs, config }:
{
  networking.hostName = "panda";
  networking.networkmanager.enable = true;

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
    openssh.authorizedKeys.keys = import ../../ssh-keys.nix;
    password = "";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  age.secrets.tailscale = {
    file = ../../secrets/tailscale-panda.age;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  users.users.root.openssh.authorizedKeys.keys = import ../../ssh-keys.nix;
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

  nix = {
    settings.auto-optimise-store = true;
    settings.trusted-users = [ "root" "pta2002" ];
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

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
