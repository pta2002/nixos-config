{
  config,
  lib,
  pkgs,
  ...
}:
let
  # TODO: This should NOT!! be here!
  secret = "2zDA8JK7yaLLeMpe9q6YdKgEeweR6ufJ971F1eFhBzqjjt5R";
  configFormat = pkgs.formats.toml { };
  configTemplate = configFormat.generate "autobrr.toml" config.services.autobrr.settings;
  templaterCmd = ''${lib.getExe pkgs.dasel} query -i toml --var "sessionSecret=\\"$(${config.systemd.package}/bin/systemd-creds cat sessionSecret)\\"" \'{ $root..., "sessionSecret": $sessionSecret }\' < ${configTemplate} > %S/autobrr/config.toml'';
in
{
  age.secrets.autobrr.rekeyFile = ../../secrets/autobrr.age;

  proxy.services.autobrr = "localhost:${toString config.services.autobrr.settings.port}";

  common.backups.paths = [ "/var/lib/private/autobrr" ];

  services.autobrr = {
    enable = true;
    secretFile = config.age.secrets.autobrr.path;
    settings = {
      host = "127.0.0.1";
      port = "7474";
      logLevel = "DEBUG";

      oidcEnabled = true;
      oidcIssuer = "https://auth.pta2002.com/oauth2/openid/autobrr";
      oidcClientId = "autobrr";
      oidcClientSecret = secret;
      oidcRedirectUrl = "https://autobrr.${config.proxy.domain}/api/auth/oidc/callback";
      oidcDisableBuiltInLogin = true;
    };
  };

  systemd.services.autobrr.after = [ "kanidm.service" ];

  systemd.services.autobrr.serviceConfig.ExecStartPre =
    lib.mkForce "${lib.getExe pkgs.bash} -c '${templaterCmd}'";

  services.kanidm.provision.systems.oauth2.autobrr = {
    originUrl = "${config.services.autobrr.settings.oidcRedirectUrl}";
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
