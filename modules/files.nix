{ pkgs, config, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  services.nginx = {
    enable = true;

    virtualHosts."files.pta2002.com" = {
      serverAliases = [ "www.files.pta2002.com" ];

      root = "/var/files";
    };
  };

  services.argoWeb = {
    enable = true;
    ingress."files.pta2002.com" = "http://localhost:80";
  };

  users.users.files = {
    group = "nginx";
    isNormalUser = true;
    home = "/var/files";
    createHome = true;
    homeMode = "755";

    openssh.authorizedKeys.keys = import ../ssh-keys.nix;
  };
}
