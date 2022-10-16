{ config, lib, ... }:
{
  imports = [
    ./argoweb.nix
  ];

  age.secrets.transmission = {
    file = ../secrets/transmission.age;
  };

  services.transmission = {
    enable = true;
    downloadDirPermissions = "777";
    openPeerPorts = true;
    settings.rpc-authentication-required = true;
    settings.rpc-host-whitelist = "transmission.pta2002.com";
    credentialsFile = config.age.secrets.transmission.path;
  };

  services.argoWeb = {
    enable = true;
    ingress."transmission.pta2002.com" = "http://localhost:9091";
  };
}
