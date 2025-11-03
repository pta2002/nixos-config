{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.attic-netrc = {
    rekeyFile = ../secrets/attic.netrc.age;
  };

  # Used by CI
  age.secrets.attic-config = {
    rekeyFile = ../secrets/attic.toml.age;
    owner = "nixuser";
    group = "nixuser";
  };

  environment.systemPackages = [ pkgs.attic-client ];

  nix.settings = {
    # TODO: https://github.com/tailscale/tailscale/issues/17687
    # substituters = lib.mkAfter [ "https://attic.minuet-puffin.ts.net/homelab-main" ];
    substituters = lib.mkAfter [ "https://attic.pta2002.com/homelab-main" ];
    trusted-public-keys = lib.mkAfter [ "homelab-main:h4K5u2G2cDloc+KyelM1vHDSGh6JzfNfK2uB31x76+s=" ];
    netrc-file = config.age.secrets.attic-netrc.path;
  };
}
