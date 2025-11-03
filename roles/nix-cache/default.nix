{ config, ... }:
{
  age.secrets.atticd-env = {
    rekeyFile = ../../secrets/atticd-env.age;
    generator.script =
      { pkgs, ... }:
      ''
        printf 'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="%s"\n' $(${pkgs.openssl}/bin/openssl genrsa -traditional 4096 | base64 -w0)
      '';
  };

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.atticd-env.path;

    settings = {
      # Had some issues with the default, hopefully this is enough.
      max-nar-info-size = 4 * 1024 * 1024;

      listen = "127.0.0.1:8332";
      jwt = { };

      storage.path = "/mnt/attic/storage";
      storage.type = "local";
    };
  };

  proxy.services.attic.addr = "127.0.0.1:8332";

  services.cloudflared.tunnels."${config.common.role.nix-cache.name}-tunnel".ingress = {
    "attic.pta2002.com" = {
      service = "http://${config.services.atticd.settings.listen}";
    };
  };
}
