{ config, ... }:
let
  # TODO: This should NOT!! be here!
  secret = "2zDA8JK7yaLLeMpe9q6YdKgEeweR6ufJ971F1eFhBzqjjt5R";
in
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
      logLevel = "DEBUG";

      # https://github.com/autobrr/autobrr/issues/1970
      oidc_enabled = true;
      oidc_issuer = "https://auth.pta2002.com/oauth2/openid/autobrr";
      oidc_client_id = "autobrr";
      oidc_client_secret = secret;
      oidc_redirect_url = "https://autobrr.${config.proxy.domain}/api/auth/oidc/callback";
      disable_built_in_login = true;
    };
  };

  systemd.services.autobrr.after = [ "kanidm.service" ];

  services.kanidm.provision.systems.oauth2.autobrr = {
    originUrl = "${config.services.autobrr.settings.oidc_redirect_url}";
    originLanding = "https://autobrr.${config.proxy.domain}";
    displayName = "autobrr";
    scopeMaps.autobrr_users = [
      "openid"
      "email"
      "profile"
    ];
    allowInsecureClientDisablePkce = true;
    preferShortUsername = true;
  };
}
