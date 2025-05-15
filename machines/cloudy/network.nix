{ config, ... }:
{
  # Secrets:
  age.secrets = {
    cloudflared = {
      rekeyFile = ../../secrets/cloudflared-cloudy-tunnel.json.age;
      mode = "400";
    };
    cf-cert = {
      rekeyFile = ../../secrets/cert-cloudy.pem.age;
      mode = "400";
    };
  };

  services.cloudflared = {
    enable = true;
    certificateFile = config.age.secrets.cf-cert.path;
    tunnels.cloudy-tunnel = {
      credentialsFile = config.age.secrets.cloudflared.path;
      certificateFile = config.age.secrets.cf-cert.path;
      default = "http_status:404";
    };
  };
}
