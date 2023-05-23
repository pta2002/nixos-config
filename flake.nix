{
  description = "My NixOS system!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nix-on-droid.url = "github:t184256/nix-on-droid";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";

    picom.url = "github:Arian8j2/picom-jonaburg-fix";
    picom.flake = false;

    vim-tup.url = "github:dunedain289/vim-tup";
    vim-tup.flake = false;

    eww-scripts.url = "file:///home/pta2002/Projects/eww-scripts";
    eww-scripts.type = "git";
    eww-scripts.inputs.nixpkgs.follows = "nixpkgs";

    phosphor-icons.url = "github:phosphor-icons/phosphor-icons/legacy";
    phosphor-icons.flake = false;

    nixvim.url = "github:pta2002/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    musnix.url = "github:musnix/musnix";

    agenix.url = "github:ryantm/agenix";

    my-switches.url = "github:pta2002/home-automation";
    my-switches.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/latest";

    hyprland.url = "github:hyprwm/Hyprland";
    hypr-contrib.url = "github:hyprwm/contrib";
    hypr-contrib.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    emacs.url = "github:nix-community/emacs-overlay";

    nixGL.url = "github:guibou/nixGL";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home, nixvim, musnix, agenix, nixos-wsl, nix-on-droid, my-switches, hyprland, nix-index-database, emacs, nixGL, ... }@inputs:
    let
      overlays = ({ pkgs, ... }: {
        nixpkgs.overlays = [
          (import ./overlays/visual-paradigm.nix pkgs)
          (import ./overlays/lua pkgs)
          (import ./overlays/my-scripts pkgs)
          emacs.overlays.default
          nixGL.overlay
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
            # home-manager.backupFileExtension = ".hm-bak";
          }
        ];

        specialArgs = {
          inherit inputs;
          hostname = name;
        };
      };
    in
    {
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
          })
        ];
        #specialArgs = { inherit inputs nixvim nixos-wsl; };
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
                (import ./modules/nvim.nix inputs)
                ./modules/git.nix
                ./modules/shell.nix
              ];
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
