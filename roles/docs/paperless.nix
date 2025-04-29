{ config, ... }:
{
  services.paperless = {
    enable = true;
    address = "127.0.0.1";

    settings = {
      # Auto-login since we're logging in via vouch-proxy.
      PAPERLESS_ADMIN_USER = "pta2002";
      PAPERLESS_AUTO_LOGIN_USERNAME = "pta2002";

      PAPERLESS_URL = "https://paperless.${config.proxy.domain}";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
    };

    database.createLocally = true;
  };

  proxy.services.paperless.addr = "127.0.0.1:${toString config.services.paperless.port}";
  proxy.services.paperless.auth.enable = true;

  # Back up paperless's data
  common.backups.paths = [ "${config.services.paperless.dataDir}" ];
}
