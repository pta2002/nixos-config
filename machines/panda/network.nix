{ config, lib, ... }:
{
  imports = [
    ../../modules/proxy.nix
  ];

  # Hostname + networkd
  networking = {
    hostName = "panda";
    networkmanager.enable = true;
    usePredictableInterfaceNames = true;
  };

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale.path;
  };

  # Proxy
  proxy = {
    enable = true;
    domain = "p.pta2002.com";
    environmentFile = config.age.secrets.caddy.path;
    ipv4 = "100.81.36.57";
    ipv6 = "fd7a:115c:a1e0::8c01:2439";
  };

  # Secrets:
  age.secrets = {
    tailscale.rekeyFile = ../../secrets/tailscale-panda.age;
    caddy.rekeyFile = ../../secrets/caddy-mars.age;
    cloudflared = {
      rekeyFile = ../../secrets/cloudflared-panda-tunnel.json.age;
      mode = "400";
    };
    cf-cert = {
      rekeyFile = ../../secrets/cert-panda.pem.age;
      mode = "400";
    };
  };

  services.cloudflared = {
    enable = true;
    certificateFile = config.age.secrets.cf-cert.path;
    tunnels.panda-tunnel = {
      credentialsFile = config.age.secrets.cloudflared.path;
      certificateFile = config.age.secrets.cf-cert.path;
      default = "http_status:404";
    };
  };

  services.k3s.extraFlags = [ "--node-ip=100.81.36.57" ];
}
