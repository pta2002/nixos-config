{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  age.secrets = {
    autheliaJwt = {
      file = ../../secrets/autheliaJwt.age;
      owner = config.services.authelia.instances.main.user;
      group = config.services.authelia.instances.main.group;
    };

    autheliaEncryptionKey = {
      file = ../../secrets/autheliaEncryptionKey.age;
      owner = config.services.authelia.instances.main.user;
      group = config.services.authelia.instances.main.group;
    };

    autheliaUsers = {
      file = ../../secrets/autheliaUsers.yaml.age;
      owner = config.services.authelia.instances.main.user;
      group = config.services.authelia.instances.main.group;
    };

    autheliaRsa = {
      file = ../../secrets/autheliaRsa.pem.age;
      owner = config.services.authelia.instances.main.user;
      group = config.services.authelia.instances.main.group;
    };

    autheliaHmac = {
      file = ../../secrets/autheliaHmac.age;
      owner = config.services.authelia.instances.main.user;
      group = config.services.authelia.instances.main.group;
    };
  };

  proxy.services.auth = "localhost:9091";

  services.authelia.instances.main = {
    enable = true;

    secrets.jwtSecretFile = config.age.secrets.autheliaJwt.path;
    secrets.storageEncryptionKeyFile = config.age.secrets.autheliaEncryptionKey.path;

    # secrets.oidcHmacSecretFile = mkIf (config.services.authelia.instances.main.settings.identity_providers.oidc.clients != []) config.age.secrets.autheliaHmac.path;
    # secrets.oidcIssuerPrivateKeyFile = mkIf (config.services.authelia.instances.main.settings.identity_providers.oidc.clients != []) config.age.secrets.autheliaRsa.path;

    settings = {
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";

      session = {
        name = "authelia_session";
        cookies = [
          {
            domain = "pta2002.com";
            authelia_url = "https://auth.p.pta2002.com";
            # default_redirection_url = "https://pta2002.com";
            name = "authelia_session";
            remember_me = "1y";
          }
        ];
      };

      notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "*.pta2002.com";
            policy = "one_factor";
          }
        ];
      };

      server.endpoints.authz.forward-auth.implementation = "ForwardAuth";

      # identity_providers.oidc.clients = [ ];

      authentication_backend.file = {
        path = config.age.secrets.autheliaUsers.path;
        password.algorithm = "argon2";
        password.argon2 = {
          variant = "argon2id";
          iterations = 3;
          memory = 65536;
          parallelism = 4;
          key_length = 32;
          salt_length = 16;
        };
      };
    };
  };
}
