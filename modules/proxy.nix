{ config, lib, pkgs, ... }:
let cfg = config.proxy;
in {
  options.proxy = {
    enable = lib.mkEnableOption "Proxy for easily exposing services via Tailscale.";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain name to use for this proxy.";
      example = "me.example.com";
    };

    listenAddresses = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [ "127.0.0.1" "::1" ];
      description = "List of host interfaces to bind to the proxy server.";
    };

    services = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = { autobrr = "http://localhost:7474"; };
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      environmentFile = cfg.environmentFile;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" ];
        hash = "sha256-jCcSzenewQiW897GFHF9WAcVkGaS/oUu63crJu7AyyQ=";
      };

      virtualHosts = {
        "*.${cfg.domain}" = {
          listenAddresses = cfg.listenAddresses;

          extraConfig = /* caddyfile */ ''
            tls {
              dns cloudflare {env.CF_API_KEY}
              resolvers 1.1.1.1
            }
          '' + (lib.concatMapStringsSep "\n"
            (service: ''
              @${service.name} host ${service.name}.${cfg.domain}
              handle @${service.name} {
                reverse_proxy ${service.value}
              }

              handle {
                respond "???"
              }
            '')
            (lib.attrsToList cfg.services));
        };
      } // (lib.mapAttrs'
        (name: _host: {
          name = "http://${name}";
          value = {
            listenAddresses = cfg.listenAddresses;

            extraConfig = ''
              redir https://${name}.${cfg.domain}{uri}
            '';
          };
        })
        cfg.services);
    };
  };
}
