{ config, ... }:
{
  age.secrets.autobrr = {
    file = ../../secrets/autobrr.age;
    # TODO: This should not be needed; the systemd service should use LoadCredential instead.
    mode = "0444";
  };

  proxy.services.autobrr = "localhost:${toString config.services.autobrr.settings.port}";
  common.backups.paths = [ "/var/lib/private/autobrr" ];

  services.autobrr = {
    enable = true;
    secretFile = config.age.secrets.autobrr.path;
    settings = {
      host = "127.0.0.1";
      port = "7474";
    };
  };
}
