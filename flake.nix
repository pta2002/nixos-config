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
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";
    nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    jetpack-nixos.url = "github:anduril/jetpack-nixos";
    jetpack-nixos.inputs.nixpkgs.follows = "nixpkgs";
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
      agenix-rekey,
      nixos-hardware,
      disko,
      deploy-rs,
      nixos-raspberrypi,
      flake-parts,
      jetpack-nixos,
      ...
    }@inputs:
    let
      overlays = {
        nixpkgs.overlays = [
          (import ./overlays/kernel)
        ];
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      debug = true;
      imports = [
        inputs.agenix-rekey.flakeModule
        inputs.treefmt-nix.flakeModule
        ./lib/cluster.nix
      ];

      flake = {
        lib.mkHomeManagerConfig =
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
              ./home/devenv.nix
              ./home/tmux.nix
              {
                programs.home-manager.enable = true;
              }
            ]
            ++ modules;
          };

        lib.overrideHomeConfiguration =
          system: config:
          home.lib.homeManagerConfiguration (
            self.lib.mkHomeManagerConfig {
              pkgs = nixpkgs.legacyPackages.${system};
              modules = [
                {
                  home.username = "pta2002";
                  home.stateVersion = "24.05";
                  home.homeDirectory = "/home/pta2002";
                }
                config
              ];
            }
          );

        homeConfigurations = {
          pta2002 = home.lib.homeManagerConfiguration (self.lib.mkHomeManagerConfig { });
          pta2002-darwin = home.lib.homeManagerConfiguration (
            self.lib.mkHomeManagerConfig {
              pkgs = nixpkgs.legacyPackages.aarch64-darwin;
              modules = [
                {
                  home.username = "ctw03386";
                  home.stateVersion = "25.11";
                  home.homeDirectory = "/Users/ctw03386";
                }
              ];
            }
          );
        };

        nixosConfigurations = {
          hydrogen = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              overlays
              ./configuration.nix
              ./machines/hydrogen.nix

              home.nixosModules.home-manager
              {
                home-manager.users.pta2002 = ./home/desktops.nix;
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  hostname = "hydrogen";
                };
                home-manager.useGlobalPkgs = true;
              }
            ];

            specialArgs = {
              inherit inputs;
              hostname = "hydrogen";
            };
          };

          pie = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              agenix.nixosModules.default
              nixos-hardware.nixosModules.raspberry-pi-4
              ./machines/pie/default.nix
            ];
          };
        };

        cluster.extraSpecialArgs = { inherit inputs; };
        cluster.extraCommonModules = [
          overlays
          agenix.nixosModules.default
          home.nixosModules.home-manager
          disko.nixosModules.disko
          agenix-rekey.nixosModules.default
        ];

        cluster.machines = {
          mars = {
            system = "aarch64-linux";
            deployHost = "100.126.178.45";
            specialArgs = {
              # Required by nixos-rasperrypi
              inherit nixos-raspberrypi;
            };
            func = nixos-raspberrypi.lib.nixosSystem;
            modules = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-5.base
              # TODO: Re-enable this once I have good CI infra
              # raspberry-pi-5.page-size-16k
            ];

            roles = [
              "home-assistant"
              "overseerr"
              "actions-runner"
              "irc"
            ];
          };

          cloudy = {
            system = "aarch64-linux";
            deployHost = "100.86.136.44";
            roles = [
              "dns"
              "vault"
              "actions-runner"
              "nix-cache"
              "fava"
              "rss"
            ];
          };

          panda = {
            system = "x86_64-linux";
            deployHost = "100.81.36.57";
            roles = [
              "actions-runner"
              "auth"
              "git"
              "snatcher"
              "stream"
            ];
          };

          dragon = {
            system = "aarch64-linux";
            deployHost = "192.168.1.131";
            roles = [ ];
          };

          nas = {
            system = "aarch64-linux";
            deployHost = "100.68.190.31";
            roles = [
              "media"
              "data-host"
            ];
          };

          jetson = {
            system = "aarch64-linux";
            deployHost = "100.74.251.44";
            modules = [ jetpack-nixos.nixosModules.default ];
            roles = [
              "actions-runner"
              # "immich"
              "garage"
              "k3s"
            ];
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

          # This might be interesting later, but for now there is no need.
          agenix-rekey.collectHomeManagerConfigurations = false;

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
