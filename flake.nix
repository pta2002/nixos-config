{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.url = "github:t184256/nix-on-droid";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    picom.url = "github:Arian8j2/picom-jonaburg-fix";
    picom.flake = false;

    vim-tup.url = "github:dunedain289/vim-tup";
    vim-tup.flake = false;

    nixvim.url = "github:pta2002/nixvim";
    # TODO: https://github.com/nix-community/nixvim/issues/1702
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home";

    my-switches.url = "github:pta2002/home-automation";
    my-switches.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/latest";
    # devenv.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    android-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
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

  outputs = { nixpkgs, home, nixvim, agenix, nixos-wsl, nix-on-droid, my-switches, raspberry-pi-nix, ... }@inputs:
    let
      overlays = ({ pkgs, ... }: {
        nixpkgs.overlays = [
          (import ./overlays/visual-paradigm.nix pkgs)
          (import ./overlays/lua pkgs)
          (import ./overlays/my-scripts pkgs)
          inputs.android-nixpkgs.overlays.default
        ];
      });

      mkMachine = name: system: nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          overlays
          ./configuration.nix
          ./machines/${name}.nix

          home.nixosModules.home-manager
          {
            home-manager.users.pta2002 = ./home.nix;
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
    in
    rec {
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [
          ./machines/droid.nix
          #home.nixosModules.home-manager
          ({ pkgs, ... }@args: {
            home-manager.config = nixpkgs.lib.mkMerge [
              { home.stateVersion = "23.05"; }
              nixvim.homeManagerModules.nixvim
              (import ./modules/nvim.nix inputs)
              {
                programs.nixvim.enable = true;
              }
              ./modules/git.nix
              ./modules/shell.nix
            ];
            home-manager.useGlobalPkgs = true;
          })
        ];
        #specialArgs = { inherit inputs nixvim nixos-wsl; };
      };

      homeManagerConfig = {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs nixvim nixos-wsl; };
        modules = [
          nixvim.homeManagerModules.nixvim
          ./modules/nvim.nix
          ./modules/git.nix
          ./modules/gpg.nix
          ./modules/shell.nix
          {
            home.stateVersion = "24.05";
            home.username = "pta2002";
            home.homeDirectory = "/home/pta2002";
            programs.home-manager.enable = true;
          }
        ];
      };

      homeConfigurations = {
        pta2002 = home.lib.homeManagerConfiguration homeManagerConfig;
      };

      nixosConfigurations = {
        hydrogen = mkMachine "hydrogen" "x86_64-linux";
        mercury = mkMachine "mercury" "x86_64-linux";

        wsl2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/wsl2.nix
            home.nixosModules.home-manager
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "23.05"; }
                nixvim.homeManagerModules.nixvim
                ./modules/nvim.nix
                ./modules/git.nix
                ./modules/shell.nix
              ];
              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "wsl2";
              };
              home-manager.useGlobalPkgs = true;
            })
          ];
          specialArgs = { inherit inputs nixvim nixos-wsl; };
        };

        cloudy = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home.nixosModules.home-manager
            ./machines/cloudy.nix
            agenix.nixosModules.default
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "22.11"; }
                nixvim.homeManagerModules.nixvim
                ./modules/nvim.nix
                ./modules/git.nix
                ./modules/shell.nix
              ];

              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "cloudy";
              };
              home-manager.useGlobalPkgs = true;
            })
          ];
          specialArgs = { inherit inputs nixvim; };
        };

        pie = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit my-switches; };
          modules = [
            home.nixosModules.home-manager
            ./machines/pie.nix
            ./modules/argoweb.nix
            agenix.nixosModules.default
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "23.05"; }
                nixvim.homeManagerModules.nixvim
                ./modules/nvim.nix
                ./modules/git.nix
                ./modules/shell.nix
              ];

              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "pie";
              };
            })
          ];
        };

        mars = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit my-switches; };
          modules = [
            agenix.nixosModules.default
            raspberry-pi-nix.nixosModules.raspberry-pi
            home.nixosModules.home-manager
            ./machines/mars.nix
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "23.11"; }
                nixvim.homeManagerModules.nixvim
                ./modules/nvim.nix
                ./modules/git.nix
                ./modules/shell.nix
              ];

              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "mars";
              };
            })
          ];
        };
      };
    };
}
