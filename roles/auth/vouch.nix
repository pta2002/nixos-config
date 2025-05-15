{ config, ... }:
{
  services.vouch-proxy = {
    enable = true;
    jwtSecretFile = config.age.secrets.vouch-secret.path;

    settings = {
      # kanidm does not really work well otherwise
      vouch = {
        domains = [ "pta2002.com" ];
        jwt = {
          # 1 year. This is internal stuff, it's fine.
          maxAge = 60 * 24 * 365;
        };

        cookie.maxAge = config.services.vouch-proxy.settings.vouch.jwt.maxAge;
      };

      oauth = {
        provider = "oidc";
        # TODO: Rename this
        client_id = "vouch-panda";
        # TODO: This should be a file
        client_secret = "H4Bg4R1UezJb8XqSNJhhXehh8ktrTewgQhhkSVz3S6SKG3Nb";
        code_challenge_method = "S256";
        token_url = "https://auth.pta2002.com/oauth2/token";
        user_info_url = "https://auth.pta2002.com/oauth2/openid/vouch-panda/userinfo";
        scopes = [
          "openid"
          "profile"
          "email"
        ];
        callback_url = "https://vouch.pta2002.com/auth";
        auth_url = "https://auth.pta2002.com/ui/oauth2";
      };
    };
  };

  services.kanidm.provision = {
    groups.proxy_users.members = [ "pta2002" ];

    # For vouch. Still TODO
    systems.oauth2.vouch-panda = {
      originLanding = "https://vouch.pta2002.com/";
      originUrl = "https://vouch.pta2002.com/auth";
      displayName = "Proxy (Panda)";
      scopeMaps.proxy_users = [
        "openid"
        "email"
        "profile"
      ];
    };
  };

  services.cloudflared.tunnels."${config.common.role.auth.name}-tunnel".ingress = {
    "vouch.pta2002.com".service =
      "http://localhost:${toString config.services.vouch-proxy.settings.vouch.port}";
  };

  age.secrets.vouch-secret.rekeyFile = ../../secrets/vouch-proxy.age;
}
