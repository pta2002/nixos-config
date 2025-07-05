{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-cloudflared.url = "github:wrbbz/nixpkgs/cloudflared-2025.4.0";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:pta2002/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home";

    my-switches.url = "github:pta2002/home-automation";
    my-switches.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.rpi-firmware-src.url = "github:raspberrypi/firmware/next";

    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    jetpack-nixos.url = "github:anduril/jetpack-nixos";
    jetpack-nixos.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://nixpkgs-unfree.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home,
      nixvim,
      agenix,
      my-switches,
      nixos-hardware,
      disko,
      deploy-rs,
      raspberry-pi-nix,
      flake-parts,
      nixpkgs-cloudflared,
      jetpack-nixos,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      imports = [
        # inputs.home.flakeModules.home-manager
        inputs.agenix-rekey.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      flake =
        let
          lib = nixpkgs.lib;

          overlays = (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                (import ./overlays/lua pkgs)
                (import ./overlays/my-scripts pkgs)
              ];
            }
          );

          mkMachine =
            name: system:
            nixpkgs.lib.nixosSystem {
              inherit system;

              modules = [
                overlays
                ./configuration.nix
                ./machines/${name}.nix

                home.nixosModules.home-manager
                {
                  home-manager.users.pta2002 = ./home/desktops.nix;
                  home-manager.extraSpecialArgs = {
                    inherit inputs;
                    hostname = name;
                  };
                  home-manager.sharedModules = [ overlays ];
                  home-manager.useGlobalPkgs = true;
                  # home-manager.backupFileExtension = ".hm-bak";
                }
              ];

              specialArgs = {
                inherit inputs;
                hostname = name;
              };
            };

          homeManagerConfig = {
            pkgs = nixpkgs.legacyPackages."x86_64-linux";
            extraSpecialArgs = { inherit inputs nixvim; };
            modules = [
              nixvim.homeManagerModules.nixvim
              ./home/nvim.nix
              ./home/git.nix
              ./home/jj.nix
              ./home/gpg.nix
              ./home/shell.nix
              {
                home.stateVersion = "24.05";
                home.username = "pta2002";
                home.homeDirectory = "/home/pta2002";
                programs.home-manager.enable = true;
              }
            ];
          };

          fs = lib.fileset;

          mkSwarmMachine =
            {
              system,
              name,
              modules ? [ ],
              stateVersion,
              specialArgs ? { },
              roles ? [ ],
            }:
            hostForRoles:
            let
              nixFilesIn = dir: fs.toList (fs.fileFilter (file: file.hasExt "nix") dir);
              machineModules = nixFilesIn ./machines/${name};
              commonModules = nixFilesIn ./common;
              roleModules = map (role: nixFilesIn ./roles/${role}) roles;
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
            nixpkgs.lib.nixosSystem {
              inherit system specialArgs;
              modules = lib.concatLists (
                [
                  [
                    (
                      { pkgs, ... }:
                      {
                        nixpkgs.overlays = [
                          (self: super: {
                            inherit (nixpkgs-cloudflared.legacyPackages.${pkgs.system}) cloudflared;
                          })
                        ];
                      }
                    )
                    agenix.nixosModules.default
                    home.nixosModules.home-manager
                    disko.nixosModules.disko

                    # Shouldn't this be by default?
                    inputs.agenix-rekey.nixosModules.default

                    ./modules/common.nix
                    roleDefinitions
                    hostForRoles

                    (
                      { ... }:
                      {
                        home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                          { home.stateVersion = stateVersion; }
                          nixvim.homeManagerModules.nixvim
                          ./home/nvim.nix
                          ./home/git.nix
                          ./home/shell.nix
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

          # TODO!
          mkSwarm =
            machines:
            let
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
            lib.mapAttrs (k: v: mkSwarmMachine v hostForRoles) machines;
        in
        {
          lib.overrideHomeConfiguration =
            system: config:
            home.lib.homeManagerConfiguration (
              homeManagerConfig
              // {
                pkgs = nixpkgs.legacyPackages.${system};
                modules = homeManagerConfig.modules ++ [ config ];
              }
            );

          homeConfigurations = {
            pta2002 = home.lib.homeManagerConfiguration homeManagerConfig;
          };

          nixosConfigurations =
            {
              hydrogen = mkMachine "hydrogen" "x86_64-linux";
              mercury = mkMachine "mercury" "x86_64-linux";

              pie = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                  agenix.nixosModules.default
                  nixos-hardware.nixosModules.raspberry-pi-4
                  ./machines/pie.nix
                ];
              };
            }
            // (mkSwarm {
              mars = {
                system = "aarch64-linux";
                name = "mars";
                stateVersion = "24.11";
                specialArgs = { inherit inputs my-switches; };
                modules = [
                  raspberry-pi-nix.nixosModules.raspberry-pi
                ];

                roles = [
                  "home-assistant"
                  "media"
                  "data-host"
                  "actions-runner"
                  "nomad-server"
                ];
              };

              cloudy = {
                system = "aarch64-linux";
                stateVersion = "22.11";
                name = "cloudy";
                specialArgs = { inherit inputs nixvim; };
                roles = [
                  "dns"
                  "vault"
                  "actions-runner"
                  "nomad-server"
                  "nix-cache"
                ];
              };

              panda = {
                system = "x86_64-linux";
                name = "panda";
                stateVersion = "25.05";
                roles = [
                  "actions-runner"
                  "auth"
                  "docs"
                  "git"
                  "snatcher"
                  "stream"
                  "nomad-lead"
                  "nomad-server"
                ];
              };

              jetson = {
                system = "aarch64";
                name = "jetson";
                stateVersion = "25.05";
                modules = [ jetpack-nixos.nixosModules.default ];
                roles = [
                  "nomad-server"
                ];
              };
            });

          deploy.nodes = {
            panda = {
              hostname = "100.81.36.57";
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.panda;
              };
            };

            cloudy = {
              hostname = "100.86.136.44";
              remoteBuild = true;
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.cloudy;
              };
            };

            mars = {
              hostname = "100.126.178.45";
              remoteBuild = true;
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.mars;
              };
            };

            jetson = {
              hostname = "100.74.251.44";
              remoteBuild = true;
              profiles.system = {
                user = "root";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.jetson;
              };
            };
          };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ config.agenix-rekey.package ];
          };

          agenix-rekey = {
            # This might be interesting later, but for now there is no need.
            collectHomeManagerConfigurations = false;
            nixosConfigurations = {
              inherit (self.nixosConfigurations)
                panda
                cloudy
                mars
                jetson
                ;
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              ruff.enable = true;
            };
          };

          packages = {
            k8s-manifests = pkgs.callPackage ./k8s/miniflux.nix { };
          };
        };
    });
}
