{ lib, ... }:
{
  users.users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix lib;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Also set up mosh
  programs.mosh.enable = true;
}
