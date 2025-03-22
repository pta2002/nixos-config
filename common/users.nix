{ pkgs, lib, ... }:
{
  environment.shells = with pkgs; [
    bash
    fish
  ];
  programs.fish.enable = true;
  users.users.pta2002 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = import ../ssh-keys.nix lib;
    password = "";
  };

  security.polkit = {
    enable = true;

    extraConfig = # js
      ''
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

  security.sudo.extraRules = [
    {
      users = [ "pta2002" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [ "pta2002" ];
}
