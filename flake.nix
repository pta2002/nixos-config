{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    picom.url = "github:Arian8j2/picom-jonaburg-fix";
    picom.flake = false;

    nixvim = {
      type = "git";
      url = "file:///home/pta2002/Projects/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
                  ./nvim.nix
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
                  ./nvim.nix
                ];
              };
            })
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
