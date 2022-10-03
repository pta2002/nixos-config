{ pkgs, config, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  services.caddy = {
    enable = true;

    virtualHosts."files.pta2002.com" = {
      serverAliases = [ "www.files.pta2002.com" ];

      extraOptions = ''
        respond "Hello, world!"
      '';
    };
  };

  services.argoWeb = {
    enable = true;
    ingress = [{
      hostname = "files.pta2002.com";
      service = "http://localhost:80";
    }];

    ingress = [{
      hostname = "www.files.pta2002.com";
      service = "http://localhost:80";
    }];
  };
}
