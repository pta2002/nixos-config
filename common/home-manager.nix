{
  lib,
  inputs,
  config,
  ...
}:
{
  home-manager.users.pta2002 = lib.mkMerge [
    { home.stateVersion = config.system.stateVersion; }
    inputs.nixvim.homeModules.nixvim
    ../home/nvim.nix
    ../home/git.nix
    ../home/shell.nix
    ../home/devenv.nix
    ../home/tmux.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    hostname = config.networking.hostName;
  };
}
