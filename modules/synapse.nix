{ pkgs, lib, config, ... }:
let
  clientConfig = {
    "m.homeserver".base_url = "https://matrix.pta2002.com";
    "m.identity_server" = { };
  };
  serverConfig."m.server" = "${config.services.matrix-synapse.settings.server_name}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  imports = [ ./argoweb.nix ];

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "matrix-synapse";
      ensurePermissions = {
        "DATABASE \"matrix-synapse\"" = "ALL PRIVILEGES";
      };
    }];

    ensureDatabases = [
      "matrix-synapse"
    ];

    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  services.nginx = {
    enable = true;
    virtualHosts."pta2002.com" = {
      enableACME = true;
      forceSSL = true;
      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
    };

    virtualHosts."matrix.pta2002.com" = {
      enableACME = false;
      forceSSL = false;
      locations."/".extraConfig = ''
        return 404;
      '';

      locations."/_matrix".proxyPass = "http://[::1]:8008";
      locations."/_synapse/client".proxyPass = "http://[::1]:8008";
    };
  };

  services.matrix-synapse = {
    enable = true;
    settings.server_name = "pta2002.com";
    settings.listeners = [{
      port = 8008;
      bind_addresses = [ "::1" ];
      type = "http";
      tls = false;
      x_forwarded = true;
      resources = [{
        names = [ "client" "federation" ];
        compress = true;
      }];
    }];
    settings.database.allow_unsafe_locale = true;
  };

  services.argoWeb = {
    enable = true;
    ingress."matrix.pta2002.com" = "http://localhost:80";
  };
}
