{ inputs }:
{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/476626 is merged.
      omnix = inputs.nixpkgs-25-11.legacyPackages.${final.stdenv.hostPlatform.system}.omnix;
    })
  ];
}
