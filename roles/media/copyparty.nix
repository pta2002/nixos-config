{ inputs, config, ... }:
{
  imports = [ inputs.copyparty.nixosModules.default ];
  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  age.secrets.copyparty-pass = {
    rekeyFile = ../../secrets/copyparty-pass.age;
    owner = config.services.copyparty.user;
    group = config.services.copyparty.group;
  };

  users.users.${config.services.copyparty.user} = {
    isSystemUser = true;
    group = config.services.copyparty.group;
  };

  services.copyparty = {
    enable = true;

    group = "data";

    settings = {
      i = "0.0.0.0";

      p = [ 3210 ];
    };

    accounts.pta2002.passwordFile = config.age.secrets.copyparty-pass.path;

    volumes."/" = {
      path = "/srv/media";
      access.A = "pta2002";

      flags = {
        # Enable filekeys
        fk = 4;
      };
    };
  };
}
