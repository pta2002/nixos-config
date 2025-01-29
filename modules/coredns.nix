{ config, pkgs, lib, ... }:
let
  domain = config.proxy.domain;
  dbfile = pkgs.writeText "db.${domain}" (''
    $ORIGIN ${domain}.
    @   IN A    100.126.178.45
        IN AAAA fd7a:115c:a1e0::2501:b22d

        IN SOA ${domain}. hostmaster.pta2002.com. (
                  2001062501 ; serial                     
                  21600      ; refresh after 6 hours                     
                  3600       ; retry after 1 hour                     
                  604800     ; expire after 1 week                     
                  86400 )    ; minimum TTL of 1 day 

  '' + (lib.concatStringsSep "\n" (lib.mapAttrsToList
    (name: _: "${name}   IN CNAME @")
    config.proxy.services)) + "\n");
in
{
  services.coredns = {
    enable = true;

    config = /* Corefile */ ''
      m.pta2002.com {
        cache 30s
        file ${dbfile}
      }

      . {
        cache 30s
        # Forward to cloudflare
        forward . tls://260:4700::1111 tls://2606:4700::1001 tls://1.1.1.1 tls://1.0.0.1 {
          tls_servername cloudflare-dns.com
          health_check 5s
        }
      }
    '';
  };
}

