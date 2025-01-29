{ pkgs, ... }:
let
  dbfile = pkgs.writeText "db.m.pta2002.com" ''
    $ORIGIN m.pta2002.com.
    @   IN A    100.126.178.45
        IN AAAA fd7a:115c:a1e0::2501:b22d

        3600 IN SOA ns.m.pta2002.com. hostmaster.pta2002.com. (
            			2001062501 ; serial                     
                  21600      ; refresh after 6 hours                     
                  3600       ; retry after 1 hour                     
                  604800     ; expire after 1 week                     
                  86400 )    ; minimum TTL of 1 day 
  '';
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

