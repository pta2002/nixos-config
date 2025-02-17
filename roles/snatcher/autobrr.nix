{ config, ... }:
let
  oidcClientId = "i7LrvADs1bXE3p8yTjeAMI.uVHXjtUajWZUaAbvMw0u3M8F3oracI4rwSZTRHibI4_FGraD~";
  oidcClientSecret = "G215rfVxHV~LRnaigiq.gus~tC3o5n4HeN1KKaDUIDnIqi0g~qjVG7c4MIEsARfXJ5DKhO0T";
  oidcClientSecretDigest = "$pbkdf2-sha512$310000$SOPZxRX5SyOhoTTgY4Lo5Q$LTcLgpQzlw2KTueaWACegdit4z6YjMu/J/HLfDToxfIvtXdBS48vcss4KqxeFkJl9EHpzalYQ.33MskQ82bncQ";
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
      oidc_issuer = "https://auth.p.pta2002.com";
      oidc_client_id = oidcClientId;
      oidc_client_secret = oidcClientSecret;
      oidc_redirect_url = "https://autobrr.${config.proxy.domain}/api/auth/oidc/callback";
      disable_built_in_login = true;
    };
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = oidcClientId;
      client_name = "autobrr";
      client_secret = oidcClientSecretDigest;
      public = false;
      authorization_policy = "one_factor";
      redirect_uris = config.services.autobrr.settings.oidc_redirect_url;
      scopes = [
        "openid"
        "profile"
        "email"
      ];
      userinfo_signed_response_alg = "none";
      token_endpoint_auth_method = "client_secret_basic";
    }
  ];
}
