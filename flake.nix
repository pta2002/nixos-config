{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";

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
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nixpkgs-25-11-rpi.url = "github:nvmd/nixpkgs/modules-with-keys-25.11";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs-25-11-rpi";

    # Keeping this around so that we can use the 25.05 kernel with RPi, which
    # supports the in-tree bcachefs module. Since the DKMS module for Linux
    # 6.12 is broken, we can't use the newer kernel package until RPi ships a
    # newer kernel.
    nixos-raspberrypi-25-05.url = "github:nvmd/nixos-raspberrypi/main";
    nixpkgs-25-05-rpi.url = "github:nvmd/nixpkgs/modules-with-keys-25.05";
    nixos-raspberrypi-25-05.inputs.nixpkgs.follows = "nixpkgs-25-05-rpi";

    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    jetpack-nixos.url = "github:anduril/jetpack-nixos";
    jetpack-nixos.inputs.nixpkgs.follows = "nixpkgs";

    copyparty.url = "github:9001/copyparty";
    copyparty.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://cache.flox.dev"
      "https://attic.c.pta2002.com/homelab-main"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "homelab-main:h4K5u2G2cDloc+KyelM1vHDSGh6JzfNfK2uB31x76+s="
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
      nixos-raspberrypi,
      nixos-raspberrypi-25-05,
      flake-parts,
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
                (final: prev: {
                  # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/476626 is merged.
                  omnix = inputs.nixpkgs-25-11.legacyPackages.${final.stdenv.hostPlatform.system}.omnix;
                })
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
                  # home-manager.sharedModules = [ overlays ];
                  home-manager.useGlobalPkgs = true;
                  # home-manager.backupFileExtension = ".hm-bak";
                }
              ];

              specialArgs = {
                inherit inputs;
                hostname = name;
              };
            };

          mkHomeManagerConfig =
            {
              pkgs ? nixpkgs.legacyPackages."x86_64-linux",
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
              extraSpecialArgs = { inherit inputs nixvim; };
              modules = [
                nixvim.homeModules.nixvim
                ./home/nvim.nix
                ./home/git.nix
                ./home/jj.nix
                ./home/gpg.nix
                ./home/shell.nix
                {
                  programs.home-manager.enable = true;
                }
              ]
              ++ modules;
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
              func ? nixpkgs.lib.nixosSystem,
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
            func {
              inherit system specialArgs;
              modules = lib.concatLists (
                [
                  [
                    overlays
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
                          nixvim.homeModules.nixvim
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
            home.lib.homeManagerConfiguration (mkHomeManagerConfig {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [
                {
                  home.username = "pta2002";
                  home.stateVersion = "24.05";
                  home.homeDirectory = "/home/pta2002";
                }
                config
              ];
            });
          lib.mkHomeManagerConfig = mkHomeManagerConfig;

          homeConfigurations = {
            pta2002 = home.lib.homeManagerConfiguration (mkHomeManagerConfig { });
            pta2002-darwin = home.lib.homeManagerConfiguration (mkHomeManagerConfig {
              pkgs = nixpkgs.legacyPackages.aarch64-darwin;
              modules = [
                {
                  home.username = "ctw03386";
                  home.stateVersion = "25.11";
                  home.homeDirectory = "/Users/ctw03386";
                }
              ];
            });
          };

          nixosConfigurations = {
            hydrogen = mkMachine "hydrogen" "x86_64-linux";

            pie = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              specialArgs = { inherit inputs; };
              modules = [
                agenix.nixosModules.default
                nixos-hardware.nixosModules.raspberry-pi-4
                ./machines/pie/default.nix
              ];
            };
          }
          // (mkSwarm {
            mars = {
              system = "aarch64-linux";
              name = "mars";
              stateVersion = "24.11";
              specialArgs = {
                inherit
                  inputs
                  my-switches
                  nixos-raspberrypi
                  nixos-raspberrypi-25-05
                  ;
              };
              func = nixos-raspberrypi.lib.nixosSystem;
              modules = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                # TODO: Re-enable this once I have good CI infra
                # raspberry-pi-5.page-size-16k
              ];

              roles = [
                "home-assistant"
                "media"
                "data-host"
                "actions-runner"
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
                # "docs"
                "git"
                "snatcher"
                "stream"
              ];
            };

            jetson = {
              system = "aarch64-linux";
              name = "jetson";
              stateVersion = "25.05";
              specialArgs = { inherit inputs; };
              modules = [
                jetpack-nixos.nixosModules.default
                (
                  { inputs, ... }:
                  {
                    nixpkgs.overlays = [
                      (final: prev: {
                        # Use the standard nix package to avoid rebuilds due to cudaSupport!
                        nix = inputs.nixpkgs.legacyPackages.aarch64-linux.nix;

                        onnxruntime = prev.onnxruntime.override { ncclSupport = false; };
                        python3-cuda = prev.python3.override {
                          packageOverrides = python-final: python-prev: {
                            # The python package does not respect ncclSupport!
                            onnxruntime = python-prev.onnxruntime.overrideAttrs {
                              buildInputs = [
                                prev.oneDNN
                                prev.re2
                                final.onnxruntime.protobuf
                                final.onnxruntime
                              ]
                              ++ lib.optionals final.onnxruntime.passthru.cudaSupport (
                                with final.onnxruntime.passthru.cudaPackages;
                                [
                                  libcublas # libcublasLt.so.XX libcublas.so.XX
                                  libcurand # libcurand.so.XX
                                  libcufft # libcufft.so.XX
                                  cudnn # libcudnn.soXX
                                  cuda_cudart # libcudart.so.XX
                                ]
                              );
                            };
                          };
                        };
                      })
                    ];
                  }
                )
              ];
              roles = [
                "actions-runner"
                "immich"
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
              remoteBuild = false;
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
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              config.agenix-rekey.package
              pkgs.age-plugin-yubikey
              pkgs.deploy-rs
            ];
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
        };
    });
}
