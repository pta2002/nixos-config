{ config, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    config.adminpassFile = config.age.secrets.nextcloud.path;
    config.extraTrustedDomains = [ "nextcloud.pta2002.com" "cloudy" ];
  };

  # Change the nextcloud port
  services.nginx.virtualHosts."localhost".listen = [{ addr = "127.0.0.1"; port = 8322; }];

  services.argoWeb = {
    enable = true;
    ingress."nextcloud.pta2002.com" = "http://localhost:8322";
  };

  age.secrets.nextcloud = {
    file = ../secrets/nextcloud.age;
    owner = "nextcloud";
  };
}
