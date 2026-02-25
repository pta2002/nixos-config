{ config, ... }:
{
  networking.networkmanager.enable = true;

  proxy = {
    enable = true;
    domain = "n.pta2002.com";
    environmentFile = config.age.secrets.caddy-mars.path;
    ipv4 = "100.68.190.31";
    ipv6 = "fd7a:115c:a1e0::b633:be1f";
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;

    extraSetFlags = [
      "--accept-routes"
    ];
  };

  age.secrets.caddy-mars.rekeyFile = ../../secrets/caddy-mars.age;
}
