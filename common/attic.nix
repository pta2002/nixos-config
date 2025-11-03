{ config, pkgs, ... }:
{
  age.secrets.attic-netrc = {
    rekeyFile = ../secrets/attic.netrc.age;
  };

  environment.systemPackages = [ pkgs.attic-client ];

  nix.settings = {
    substituters = [ "https://attic.minuet-puffin.ts.net/homelab-main" ];
    trusted-public-keys = [ "homelab-main:h4K5u2G2cDloc+KyelM1vHDSGh6JzfNfK2uB31x76+s=" ];
    netrc-file = config.age.secrets.attic-netrc.path;
  };
}
