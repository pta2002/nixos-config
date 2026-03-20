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
  nixFilesIn = dir: fs.toList (fs.fileFilter (file: file.hasExt "nix") dir);
  availableRoles = builtins.attrNames (builtins.readDir ../roles);

  nixpkgs = inputs.nixpkgs;

  commonModules = (nixFilesIn ../common) ++ cfg.extraCommonModules;

  machineSubmodule = types.submodule (
    { config, name, ... }:
    {
      options = {
        system = lib.mkOption {
          type = types.str;
          description = "System string of the machine";
        };

        deployHost = lib.mkOption {
          type = types.str;
          description = "Hostname on which this machine can be reached";
        };

        roles = lib.mkOption {
          type = types.listOf (types.enum availableRoles);
          default = [ ];
          description = "List of roles for this host to take on";
        };

        specialArgs = lib.mkOption {
          type = types.attrsOf types.raw;
          default = { };
          description = "Arguments to be passed to the NixOS configuration";
        };

        func = lib.mkOption {
          type = types.functionTo types.raw;
          default = nixpkgs.lib.nixosSystem;
          description = "Function used to compute the NixOS configuration";
        };

        modules = lib.mkOption {
          type = types.listOf types.deferredModule;
          default = [ ];
          description = "Extra modules to be loaded in this machine";
        };

        nixosConfiguration = lib.mkOption {
          type = types.raw;
          description = "NixOS configuration generated for this machine";
        };
      };

      config.nixosConfiguration = mkClusterMachine {
        inherit (config)
          system
          deployHost
          modules
          specialArgs
          roles
          func
          ;
        inherit name;
      };
    }
  );

  mkClusterMachine =
    {
      system,
      name,
      deployHost,
      modules ? [ ],
      specialArgs ? { },
      roles ? [ ],
      func ? nixpkgs.lib.nixosSystem,
    }:
    let
      machineModules = nixFilesIn ../machines/${name};
      roleModules = lib.flatten (map (role: cfg.roles.${role}.modules) roles);
      clusterDefinitions = {
        cluster = {
          inherit deployHost;
        };

        _module.args.cluster = {
          inherit (cfg) roles;
          myRoles = roles;
        };
      };
    in
    func {
      inherit system;
      specialArgs = cfg.extraSpecialArgs // specialArgs;

      modules = lib.flatten [
        ../modules/cluster.nix
        clusterDefinitions
        machineModules
        commonModules
        modules
        roleModules
      ];
    };

  roleSubmodule = types.submodule (
    { name, ... }:
    {
      options = {
        modules = lib.mkOption {
          type = types.listOf types.deferredModule;
          description = "This role's modules";
        };

        hosts = lib.mkOption {
          type = types.listOf types.str;
          description = "The hosts that have this role";
        };
      };

      config = {
        modules = nixFilesIn ../roles/${name};
        hosts = lib.attrNames (lib.filterAttrs (_: m: lib.elem name m.roles) cfg.machines);
      };
    }
  );
in
{
  options.flake.cluster = {
    roles = lib.mkOption {
      type = types.attrsOf roleSubmodule;
      description = "Roles available to be selected, and their modules";
    };

    extraSpecialArgs = lib.mkOption {
      type = lib.types.attrsOf types.raw;
      default = { };
      description = "Extra arguments to be available in the configuration's specialArgs";
    };

    extraCommonModules = lib.mkOption {
      type = lib.types.listOf types.deferredModule;
      default = [ ];
      description = "Extra modules to be imported in all configurations";
    };

    machines = lib.mkOption {
      type = lib.types.attrsOf machineSubmodule;
      default = { };
      description = "NixOS configurations for cluster members";
    };
  };

  config.flake = {
    cluster = {
      roles = lib.genAttrs availableRoles (lib.const { });
    };

    nixosConfigurations = lib.mapAttrs (_: machine: machine.nixosConfiguration) cfg.machines;

    deploy.nodes = lib.mapAttrs (name: machine: {
      hostname = machine.deployHost;
      remoteBuild = true;
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.${machine.system}.activate.nixos machine.nixosConfiguration;
      };
    }) cfg.machines;
  };
}
