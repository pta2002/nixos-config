{ config, pkgs, ... }:
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        DOMAIN = "forgejo.${config.proxy.domain}";
        HTTP_PORT = 40123;
        ROOT_URL = "https://forgejo.${config.proxy.domain}/";
      };

      service = {
        DISABLE_REGISTRATION = true;
      };

      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        USERNAME = "nickname";
        UPDATE_AVATAR = true;
        ACCOUNT_LONKING = "auto";
      };
    };
  };

  proxy.services.forgejo = "localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";

  services.kanidm.provision = {
    groups.forgejo_users.members = [ "pta2002" ];

    systems.oauth2.forgejo = {
      originUrl = "${config.services.forgejo.settings.server.ROOT_URL}user/oauth2/kanidm/callback";
      originLanding = "https://forgejo.${config.proxy.domain}";
      displayName = "forgejo";
      scopeMaps.forgejo_users = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      allowInsecureClientDisablePkce = true;
    };
  };
}
