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
      # TODO: This should not depend on the port.
      authEndpint = "http://${config.common.role.auth.name}:9090/validate";
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

        generatedNginxConfig = lib.mkOption {
          type = lib.types.attrsOf (lib.types.anything);
          readOnly = true;
        };
      };

      config = {
        generatedNginxConfig."${name}.${cfg.domain}" = lib.mkMerge (
          [
            {
              # Use the wildcard certificate
              useACMEHost = cfg.domain;
              forceSSL = true;

              locations."/" = {
                recommendedProxySettings = true;
                proxyPass = "http://${config.addr}";

                extraConfig =
                  lib.mkDefault # nginx
                    ''
                      # For websockets upgrade
                      proxy_set_header Upgrade $http_upgrade;
                      proxy_set_header Connection $connection_upgrade;
                    '';
              };
            }
            (lib.mkIf config.auth.enable {
              locations."= /validate" = {
                proxyPass = authEndpint;
                extraConfig = # nginx
                  ''
                    # Tell nginx that it should use the vouch.pta2002.com domain for the SSL validation
                    # proxy_ssl_server_name on;
                    proxy_set_header Host $host;
                    proxy_pass_request_body off;
                    proxy_set_header Content-Length "";
                    auth_request_set $auth_resp_x_vouch_user $upstream_http_x_vouch_user;
                    auth_request_set $auth_resp_jwt $upstream_http_x_vouch_jwt;
                    auth_request_set $auth_resp_err $upstream_http_x_vouch_err;
                    auth_request_set $auth_resp_failcount $upstream_http_x_vouch_failcount;
                  '';
              };

              locations."/".extraConfig = # nginx
                ''
                  auth_request /validate;

                  proxy_set_header X-Vouch-User $auth_resp_x_vouch_user;

                  # For websockets upgrade
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection $connection_upgrade;

                  # if validate returns `401 not authorized` then forward the request to the error401 block
                  error_page 401 = @error401;
                '';

              locations."@error401" = {
                extraConfig = # nginx
                  ''
                    return 302 https://vouch.pta2002.com/login?url=$scheme://$http_host$request_uri&vouch-failcount=$auth_resp_failcount&X-Vouch-Token=$auth_resp_jwt&error=$auth_resp_err;
                  '';
              };
            })
          ]
          ++ (builtins.map (endpoint: {
            locations.${endpoint} = {
              recommendedProxySettings = true;
              proxyPass = "http://${config.addr}";
            };
          }) config.auth.excluded)
        );
      };
    };
in
{
  imports = [
    ./vouch-proxy.nix
  ];

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

      security.acme.certs."${cfg.domain}" = {
        domain = cfg.domain;
        extraDomainNames = [ "*.${cfg.domain}" ];
        # Use cloudflare's DNS resolver, because we are running coredns locally.
        dnsResolver = "1.1.1.1:53";
        dnsProvider = "cloudflare";
        environmentFile = cfg.environmentFile;
        group = config.services.nginx.group;
      };

      systemd.services.nginx.after = [ "tailscaled.service" ];
      services.nginx = {
        enable = true;
        virtualHosts = lib.mkMerge (
          [
            {
              "*.${cfg.domain}" = {
                forceSSL = true;
                useACMEHost = cfg.domain;
              };
            }
          ]
          ++ lib.mapAttrsToList (_: service: service.generatedNginxConfig) services
        );
      };
    };
}
