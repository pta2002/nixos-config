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

    ipv4 = lib.mkOption {
      type = with lib.types; str;
      example = [ "127.0.0.1" ];
      description = "Tailscale IPv4 address.";
    };

    ipv6 = lib.mkOption {
      type = with lib.types; str;
      example = [ "::1" ];
      description = "Tailscale IPv6 address.";
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
    services.coredns = {
      enable = true;
      config =
        let
          dbfile = pkgs.writeText "db.${cfg.domain}" (''
            $ORIGIN ${cfg.domain}.
            @   IN A    ${cfg.ipv4}
                IN AAAA ${cfg.ipv6}

                IN SOA ${cfg.domain}. hostmaster.pta2002.com. (
                          2001062501 ; serial                     
                          21600      ; refresh after 6 hours                     
                          3600       ; retry after 1 hour                     
                          604800     ; expire after 1 week                     
                          86400 )    ; minimum TTL of 1 day 

          '' + (lib.concatStringsSep "\n" (lib.mapAttrsToList
            (name: _: "${name}   IN CNAME @")
            cfg.services)) + "\n");
        in
          /* Corefile */ ''
          ${cfg.domain} {
            cache 30s
            file ${dbfile}
          }

          . {
            cache 30s
            # Forward to cloudflare
            forward . tls://2606:4700::1111 tls://2606:4700::1001 tls://1.1.1.1 tls://1.0.0.1 {
              tls_servername cloudflare-dns.com
              health_check 5s
            }
          }
        '';
    };

    services.caddy = {
      enable = true;
      environmentFile = cfg.environmentFile;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" ];
        hash = "sha256-jCcSzenewQiW897GFHF9WAcVkGaS/oUu63crJu7AyyQ=";
      };

      virtualHosts = {
        "*.${cfg.domain}" = {
          listenAddresses = [ cfg.ipv4 cfg.ipv6 ];

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
            listenAddresses = [ cfg.ipv4 cfg.ipv6 ];

            extraConfig = ''
              redir https://${name}.${cfg.domain}{uri}
            '';
          };
        })
        cfg.services);
    };
  };
}
