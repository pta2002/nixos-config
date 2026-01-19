{ inputs, lib }:
{
  mkMachine =
    name: system:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        (import ./overlays.nix { inherit inputs; })
        ../configuration.nix
        ../machines/${name}.nix

        inputs.home.nixosModules.home-manager
        {
          home-manager.users.pta2002 = ../home/desktops.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            hostname = name;
          };
          home-manager.useGlobalPkgs = true;
        }
      ];

      specialArgs = {
        inherit inputs;
        hostname = name;
      };
    };

  mkHomeManagerConfig =
    {
      pkgs ? inputs.nixpkgs.legacyPackages."x86_64-linux",
      modules ? [
        {
          home.stateVersion = "24.05";
          home.username = "pta2002";
          home.homeDirectory = "/home/pta2002";
        }
      ],
    }:
    {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        nixvim = inputs.nixvim;
      };
      modules = [
        inputs.nixvim.homeModules.nixvim
        ../home/nvim.nix
        ../home/git.nix
        ../home/jj.nix
        ../home/gpg.nix
        ../home/shell.nix
        {
          programs.home-manager.enable = true;
        }
      ] ++ modules;
    };

  mkSwarmMachine =
    {
      system,
      name,
      modules ? [ ],
      stateVersion,
      specialArgs ? { },
      roles ? [ ],
      func ? inputs.nixpkgs.lib.nixosSystem,
    }:
    hostForRoles:
    let
      fs = lib.fileset;
      nixFilesIn = dir: fs.toList (fs.fileFilter (file: file.hasExt "nix") dir);
      machineModules = nixFilesIn ../machines/${name};
      commonModules = nixFilesIn ../common;
      roleModules = map (role: nixFilesIn ../roles/${role}) roles;
      roleDefinitions = {
        config.common.role = lib.listToAttrs (
          map (role: {
            name = role;
            value = {
              enabled = true;
            };
          }) roles
        );
      };
    in
    func {
      inherit system specialArgs;
      modules = lib.concatLists (
        [
          [
            (import ./overlays.nix { inherit inputs; })
            inputs.agenix.nixosModules.default
            inputs.home.nixosModules.home-manager
            inputs.disko.nixosModules.disko
            inputs.agenix-rekey.nixosModules.default

            ../modules/common.nix
            roleDefinitions
            hostForRoles

            (
              { ... }:
              {
                home-manager.users.pta2002 = inputs.nixpkgs.lib.mkMerge [
                  { home.stateVersion = stateVersion; }
                  inputs.nixvim.homeModules.nixvim
                  ../home/nvim.nix
                  ../home/git.nix
                  ../home/shell.nix
                ];

                home-manager.useGlobalPkgs = true;
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  hostname = name;
                };
              }
            )
          ]
          machineModules
          commonModules
          modules
        ]
        ++ roleModules
      );
    };

  mkSwarm =
    machines:
    let
      mkSwarmMachine = inputs.self.lib.mkSwarmMachine or (builtins.getAttr "mkSwarmMachine" (import ./machines.nix { inherit inputs lib; }));
      rolesPerHost = lib.mapAttrs (k: v: v.roles) machines;
      hostForRoles =
        let
          flattened = lib.flatten (
            lib.mapAttrsToList (
              host:
              map (role: {
                ${role}.name = host;
              })
            ) rolesPerHost
          );
        in
        {
          config.common.role = lib.mergeAttrsList flattened;
        };
    in
    lib.mapAttrs (k: v: (mkSwarmMachine v) hostForRoles) machines;
}
