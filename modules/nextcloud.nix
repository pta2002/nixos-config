{ config, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  services.nextcloud = {
    enable = true;
    hostName = "localhost:8322";
    config.adminPassFile = config.age.secrets.nextcloud.path;
  };

  services.argoweb = {
    enable = true;
    ingress = [{
      hostname = "nextcloud.pta2002.com";
      service = "localhost:8322";
    }];
  };

  age.secrets.nextcloud.path = ../secrets/nextcloud.age;
}
