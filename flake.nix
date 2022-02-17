{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home.url = "github:nix-community/home-manager/release-21.11";
    home.inputs.nixpkgs.follows = "nixpkgs";

    /* nixvim.url = "github:pta2002/nixvim"; */
    nixvim = {
      type = "git";
      url = "file:///home/pta2002/Projects/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home, nixvim, ... }@inputs: {
    nixosConfigurations = {
      mercury = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({pkgs, ...}: {
            nixpkgs.overlays = [ (import ./overlays/visual-paradigm.nix pkgs) ];
          })
          ./configuration.nix
          home.nixosModules.home-manager
          ({pkgs, ...}@args: {
            home-manager.users.pta2002 = import ./home.nix args // {
              imports = [
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
