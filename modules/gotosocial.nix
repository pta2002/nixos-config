{ config, pkgs, lib, inputs, ... }:
let
  configFile = pkgs.writeTextFile {
    name = "gotosocial.yaml";
    text = builtins.toJSON {
      host = "social.pta2002.com";
      db-type = "sqlite";
      db-address = "sqlite.db";
      storage-local-base-path = "/var/lib/gotosocial";
      web-template-base-dir = "${inputs.extras.packages.${pkgs.system}.gotosocial}/web/template/";
      web-asset-base-dir = "${inputs.extras.packages.${pkgs.system}.gotosocial}/web/assets/";
      letsencrypt-enabled = false;
      port = 8888;
    };
  };
in
{
  imports = [
    ./argoweb.nix
  ];

  users.users.gotosocial = {
    isSystemUser = true;
    group = "gotosocial";
    home = "/var/lib/gotosocial";
  };

  environment.systemPackages = [
    inputs.extras.packages.${pkgs.system}.gotosocial
  ];

  systemd.services.gotosocial = {
    description = "gotosocial";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "on-failure";
      User = "gotosocial";
      StateDirectory = "gotosocial";
      ExecStart = "${inputs.extras.packages.${pkgs.system}.gotosocial}/bin/gotosocial --config-path ${configFile} server start";

      WorkingDirectory = "/var/lib/gotosocial";
    };
  };

  services.argoWeb = {
    enable = true;
    ingress."social2.pta2002.com" = "http://127.0.0.1:8888";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."social.pta2002.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8888";
        proxyWebsockets = true;
      };
      extraConfig = ''
        client_max_body_size 40M;
      '';
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "pta2002@pta2002.com";

  networking.firewall.allowedUDPPorts = [ 80 443 ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
