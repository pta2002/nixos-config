{
  users.users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
}
