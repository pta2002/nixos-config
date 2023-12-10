# This is absolute insanity and it should probably not work!
# Many thanks to https://gist.github.com/betaboon/97abed457de8be43f89e7ca49d33d58d

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.boot.loader.refind;
  efi = config.boot.loader.efi;
  refindBuilder = pkgs.substituteAll {
    src = ./install-refind.py;
    isExecutable = true;
    nix = config.nix.package.out;
    timeout = if config.boot.loader.timeout != null then config.boot.loader.timeout else "";
    extraConfig = cfg.extraConfig;
    extraIcons = if cfg.extraIcons != null then cfg.extraIcons else "";
    # TODO
    extraThemes = if cfg.extraThemes != [] then builtins.head cfg.extraThemes else "";
    inherit (pkgs) python3 refind efibootmgr coreutils gnugrep gnused gawk utillinux findutils;
    inherit (efi) efiSysMountPoint canTouchEfiVariables;
  };
in
{
  options.boot.loader.refind = {
    enable = mkEnableOption "rEFInd boot manager";
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to refind.conf";
    };

    extraIcons = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "A directory containing icons to be copied to 'extra-icons'";
    };

    extraThemes = mkOption {
      type = (types.listOf types.path);
      default = [];
      description = "A list of directories containing themes to be copied to 'themes'";
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = (config.boot.loader.kernelPackages.kernel.features or { efiBootStub = true; }) ? efiBootStub;
      message = "This kernel does not support the EFI boot stub";
    }];

    # Needed because NixOS enables GRUB by default
    boot.loader.grub.enable = mkDefault false;

    system = {
      build.installBootLoader = refindBuilder;
      boot.loader.id = "refind";
      requiredKernelConfig = with config.lib.kernelConfig; [ (isYes "EFI_STUB") ];
    };
  };
}
