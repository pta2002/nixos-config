{ config, pkgs, ... }: {
  # services.argoWeb = {
  #   enable = true;
  #   ingress."social.pta2002.com" = "http://127.0.0.1:80";
  #   ingress."pta2002.com" = "http://127.0.0.1:80";
  #   ingress."www.pta2002.com" = "http://127.0.0.1:80";
  # };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."pta2002.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/.well-known/webfinger" = {
        extraConfig = ''
          return 301 https://fedi.pta2002.com$request_uri;
        '';
      };
    };

    virtualHosts."fedi.pta2002.com" = {
      enableACME = true;
      forceSSL = true;

      root = "${config.services.mastodon.package}/public/";

      locations."/system/".alias = "/var/lib/mastodon/public-system/";

      locations."/" = {
        tryFiles = "$uri @proxy";
      };

      locations."@proxy" = {
        # proxyPass = "http://unix:/run/mastodon-web/web.socket";
        proxyPass = "http://127.0.0.1:55001";
        proxyWebsockets = true;
      };

      locations."/api/v1/streaming/" = {
        # proxyPass = "http://unix:/run/mastodon-streaming/streaming.socket";
        proxyPass = "http://127.0.0.1:55000";
        proxyWebsockets = true;
      };
    };
  };

  services.elasticsearch.enable = true;
  services.elasticsearch.package = pkgs.elasticsearch7;

  services.mastodon = {
    enable = true;
    enableUnixSocket = false;
    configureNginx = false;
    localDomain = "pta2002.com";
    extraConfig = {
      WEB_DOMAIN = "fedi.pta2002.com";
      SINGLE_USER_MODE = "true";
      EMAIL_DOMAIN_ALLOWLIST = "pta2002.com";
    };

    smtp.fromAddress = "mastodon@pta2002.com";

    elasticsearch.host = "localhost";
  };

  users.users.nginx.extraGroups = [ "mastodon" ];
}
