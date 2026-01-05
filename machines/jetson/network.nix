{ config, ... }:
{
  imports = [ ../../modules/proxy.nix ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;

    extraSetFlags = [
      "--accept-routes"
    ];
  };

  proxy = {
    enable = true;
    domain = "j.pta2002.com";
    ipv4 = "100.74.251.44";
    ipv6 = "fd7a:115c:a1e0::cc33:fb2c";
    environmentFile = config.age.secrets.caddy-mars.path;
  };

  age.secrets.caddy-mars.rekeyFile = ../../secrets/caddy-mars.age;
}
