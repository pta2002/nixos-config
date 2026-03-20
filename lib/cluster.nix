{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.flake.cluster;

  fs = lib.fileset;
  nixpkgs = inputs.nixpkgs;

  mkClusterMachine =
    {
      system,
      name,
      modules ? [ ],
      specialArgs ? { },
      roles ? [ ],
      func ? nixpkgs.lib.nixosSystem,
    }:
    let
      nixFilesIn = dir: fs.toList (fs.fileFilter (file: file.hasExt "nix") dir);
      machineModules = nixFilesIn ../machines/${name};
      commonModules = (nixFilesIn ../common) ++ cfg.extraCommonModules;
      roleModules = map (role: nixFilesIn ../roles/${role}) roles;
      roleDefinitions = {
        config.cluster.roles = roles;
      };
    in
    func {
      inherit system;
      specialArgs = cfg.extraSpecialArgs // specialArgs;

      modules = lib.concatLists (
        [
          [
            ../modules/cluster.nix
            roleDefinitions
          ]
          machineModules
          commonModules
          modules
        ]
        ++ roleModules
      );
    };
  mkCluster = lib.mapAttrs (name: v: mkClusterMachine (v // { inherit name; }));
in
{
  options.flake.cluster = {
    extraSpecialArgs = lib.mkOption {
      type = lib.types.attrsOf types.raw;
      default = { };
      description = "Extra arguments to be available in the configuration's specialArgs";
    };

    extraCommonModules = lib.mkOption {
      # TODO: I think there might be a better type here?
      type = lib.types.listOf types.raw;
      default = [ ];
      description = "Extra modules to be imported in all configurations";
    };

    machines = lib.mkOption {
      # TODO: This should probably be a deferred module?
      type = lib.types.attrsOf types.raw;
      default = { };
      description = "NixOS configurations for cluster members";
    };
  };

  config.flake = {
    nixosConfigurations = mkCluster cfg.machines;
  };
}
