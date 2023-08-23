{
  description = "My NixOS system!";

  inputs = {
    # nixpkgs.url = "github:numtide/nixpkgs-unfree";
    # nixpkgs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/285aa1f48e62932fed2089ddb04768172ae4a625";
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

    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    android-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://cuda-maintainers.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-unfree.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
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
          inputs.android-nixpkgs.overlays.default

          (final: prev: {
            opencv4 = prev.opencv4.override {
              enableCuda = false;
            };
          })
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
                ./modules/nvim.nix
                ./modules/git.nix
                ./modules/shell.nix
              ];
              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "wsl2";
              };
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

              home-manager.extraSpecialArgs = {
                inherit inputs;
                hostname = "pie";
              };
            })
          ];
        };
      };
    };
}
