{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixpkgs";

    # nixvim.url = "github:pta2002/nixvim";
    nixvim = {
      type = "git";
      url = "file:///home/pta2002/Projects/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home, nixvim, ... }@inputs:
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
            ./configuration.nix
            ./machines/hydrogen.nix
            home.nixosModules.home-manager
            ({ pkgs, ... }@args: {
              home-manager.users.pta2002 = import ./home.nix args // {
                imports = [
                  nixvim.homeManagerModules.x86_64-linux.nixvim
                ];
              };
            })
          ];
          specialArgs = { inherit inputs; };
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
                ];
              };
            })
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
