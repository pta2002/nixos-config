{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.proxy;

  serviceOpts =
    let
      auth_endpoint = "${config.common.role.auth.name}:9091";
    in
    { name, config, ... }:
    {
      options = {
        addr = lib.mkOption {
          type = lib.types.str;
          description = "Address";
        };

        auth = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to enable authentication for this endpoint";
            default = false;
          };

          excluded = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "List of endpoints to exclude from auth";
            default = [ ];
          };
        };

        generatedConfig = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
        };
      };

      config.generatedConfig = ''
        @${name} host ${name}.${cfg.domain}
        handle @${name} {
          ${lib.optionalString config.auth.enable (
            lib.concatMapStringsSep "\n" (endpoint: ''
              handle ${endpoint} {
                reverse_proxy ${config.addr}
              }
            '') config.auth.excluded
          )}
          handle {
            ${lib.optionalString config.auth.enable ''
              forward_auth ${auth_endpoint} {
                 uri /api/authz/forward-auth
                 copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
               }
            ''}

            reverse_proxy ${config.addr}
          }
        }
      '';
    };
in
{
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
      type = with lib.types; attrsOf (either str (submodule serviceOpts));
      default = { };
      example = {
        autobrr = "http://localhost:7474";
        sonarr = {
          addr = "http://localhost:7474";
        };
      };
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config =
    let
      services = lib.mapAttrs (
        name: val:
        if builtins.isString val then
          (serviceOpts {
            inherit name;
            config = {
              addr = val;
              auth = {
                enable = false;
                excluded = [ ];
              };
            };
          }).config
        else
          val
      ) cfg.services;
    in
    lib.mkIf cfg.enable {
      services.coredns = {
        enable = true;
        config =
          let
            dbfile = pkgs.writeText "db.${cfg.domain}" (
              ''
                $ORIGIN ${cfg.domain}.
                @   IN A    ${cfg.ipv4}
                    IN AAAA ${cfg.ipv6}

                    IN SOA ${cfg.domain}. hostmaster.pta2002.com. (
                              2001062501 ; serial                     
                              21600      ; refresh after 6 hours                     
                              3600       ; retry after 1 hour                     
                              604800     ; expire after 1 week                     
                              86400 )    ; minimum TTL of 1 day 

              ''
              + (lib.concatStringsSep "\n" (lib.mapAttrsToList (name: _: "${name}   IN CNAME @") cfg.services))
              + "\n"
            );
          in
          # Corefile
          ''
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

      systemd.services.caddy.after = [ "tailscaled.service" ];

      services.caddy = {
        enable = true;
        environmentFile = cfg.environmentFile;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e" ];
          hash = "sha256-JVkUkDKdat4aALJHQCq1zorJivVCdyBT+7UhqTvaFLw=";
        };

        # extraConfig = ''
        #   trusted_proxies 100.0.0.0/8 192.168.0.0/16 fd7a:115c:a1e0::/48 127.0.0.1/32
        # '';

        virtualHosts =
          {
            "*.${cfg.domain}" = {
              # listenAddresses = [ cfg.ipv4 cfg.ipv6 ];

              extraConfig = lib.mkMerge (
                [
                  ''
                    tls {
                      dns cloudflare {env.CF_API_KEY}
                      resolvers 1.1.1.1
                    }
                  ''
                ]
                ++ (lib.mapAttrsToList (_: service: service.generatedConfig) services)
                ++ [
                  ''
                    handle {
                      respond "???"
                    }
                  ''
                ]
              );
            };
          }
          // (lib.mapAttrs' (name: _host: {
            name = "http://${name}";
            value = {
              # listenAddresses = [ cfg.ipv4 cfg.ipv6 ];

              extraConfig = ''
                redir https://${name}.${cfg.domain}{uri}
              '';
            };
          }) cfg.services);
      };
    };
}
