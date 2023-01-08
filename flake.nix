{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    picom.url = "github:Arian8j2/picom-jonaburg-fix";
    picom.flake = false;

    vim-tup.url = "github:dunedain289/vim-tup";
    vim-tup.flake = false;

    eww-scripts.url = "file:///home/pta2002/Projects/eww-scripts";
    eww-scripts.type = "git";
    eww-scripts.inputs.nixpkgs.follows = "nixpkgs";

    phosphor-icons.url = "github:phosphor-icons/phosphor-icons";
    phosphor-icons.flake = false;

    nixvim.url = "github:pta2002/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix";

    agenix.url = "github:ryantm/agenix";

    extras.url = "./extras";
    extras.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home, nixvim, musnix, agenix, extras, ... }@inputs:
    let
      overlays = ({ pkgs, ... }: {
        nixpkgs.overlays = [
          (import ./overlays/visual-paradigm.nix pkgs)
          (import ./overlays/lua pkgs)
          (import ./overlays/my-scripts pkgs)
        ];
      });
    in
    {
      nixosConfigurations = {
        hydrogen = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            overlays
            musnix.nixosModules.musnix
            ./configuration.nix
            ./machines/hydrogen.nix
            home.nixosModules.home-manager

            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                (import ./home.nix args)
                {
                  imports = [
                    nixvim.homeManagerModules.nixvim
                    (import ./modules/nvim.nix inputs)
                  ];
                }
              ];
            })
          ];
          specialArgs = { inherit inputs musnix nixvim; };
        };

        mercury = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            overlays
            ./configuration.nix
            ./machines/mercury.nix
            home.nixosModules.home-manager
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                (import ./home.nix args)
                {
                  imports = [
                    nixvim.homeManagerModules.nixvim
                    (import ./modules/nvim.nix inputs)
                  ];
                }
              ];
            })
          ];
          specialArgs = { inherit inputs nixvim; };
        };

        cloudy = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home.nixosModules.home-manager
            ./cloudy.nix
            agenix.nixosModule
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "22.11"; }
                nixvim.homeManagerModules.nixvim
                (import ./modules/nvim.nix inputs)
                ./modules/git.nix
                ./modules/shell.nix
              ];
            })
          ];
          specialArgs = { inherit inputs nixvim; };
        };

        pie = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home.nixosModules.home-manager
            ./machines/pie.nix
            ./modules/argoweb.nix
            agenix.nixosModule
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = nixpkgs.lib.mkMerge [
                { home.stateVersion = "23.05"; }
                nixvim.homeManagerModules.nixvim
                (import ./modules/nvim.nix inputs)
                ./modules/git.nix
                ./modules/shell.nix
              ];
            })
          ];
        };
      };
    };
}
