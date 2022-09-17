{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs = { self, nixpkgs, home, nixvim, musnix, ... }@inputs:
    let
      overlays = ({ pkgs, ... }: {
        nixpkgs.overlays = [
          (import ./overlays/visual-paradigm.nix pkgs)
          (import ./overlays/lua pkgs)
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
              home-manager.users.pta2002 = import ./home.nix args // {
                imports = [
                  # nixvim.homeManagerModules.x86_64-linux.nixvim
                  nixvim.homeManagerModules.nixvim
                  (import ./nvim.nix inputs)
                ];
              };
            })
          ];
          specialArgs = { inherit inputs musnix nixvim; };
        };
        nixvim-machine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # ./configuration.nix
            # home.nixosModules.home-manager

            # ./nvim.nix
            # nixvim.nixosModules.x86_64-linux.nixvim
            ({ pkgs, ... }: {
              environment.systemPackages = [
                (nixvim.build pkgs { colorschemes.gruvbox.enable = true; })
              ];
            })

          ];
          # specialArgs = { inherit inputs musnix nixvim; };
        };

        mercury = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            overlays
            ./configuration.nix
            ./machines/mercury.nix
            home.nixosModules.home-manager
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = import ./home.nix args // {
                imports = [
                  # nixvim.homeManagerModules.x86_64-linux.nixvim
                  nixvim.homeManagerModules.nixvim
                  (import ./nvim.nix inputs)
                ];
              };
            })
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
