{ pkgs, lib, ... }:
{
  home.stateVersion = "21.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Programming languages
    gcc gnumake
    jdk17 maven
    texlive.combined.scheme-full
    nodejs
    python3

    # Utilities
    ripgrep fd exa
    any-nix-shell
    unzip
    libqalculate
    httpie
    jq
    gh

    # Random programs
    discord
    spotify
    texmacs
    minecraft
    # visual-paradigm
    calibre
    signal-desktop
    tdesktop
    zotero
    libreoffice
    obsidian

    # IDEs
    jetbrains.idea-ultimate
    jetbrains.datagrip
    jetbrains.clion
    android-studio

    # Libraries and stuff
    sqlite

    # Random things like fonts
    jetbrains-mono
    (nerdfonts.override { fonts = ["JetBrainsMono" "FiraCode"]; })
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.firefox.enable = true;

  programs.git = {
    enable = true;
    userName = "Pedro Alves";
    userEmail = "pta2002@pta2002.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      diff.colorMoved = "zebra";
      core.autocrlf = "input";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      any-nix-shell fish | source
      base16-gruvbox-dark-hard
    '';

    shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      g = "git";
      gp = "git push";
      gc = "git commit";
      gpl = "git pull";

      ls = "exa";
    };
    plugins = [
      {
        name = "base16-fish";
        src = pkgs.fetchFromGitHub {
          owner = "tomyun";
          repo = "base16-fish";
          rev = "2f6dd973a9075dabccd26f1cded09508180bf5fe";
          sha256 = "sha256-PebymhVYbL8trDVVXxCvZgc0S5VxI7I1Hv4RMSquTpA=";
        };
      }
    ];
  };

  programs.starship = {
    enable = false; # TODO: This is broken :(
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
    };

    enableFishIntegration = true;
  };

  programs.nixvim = {
    enable = true;
    plugins = {
      treesitter.enable = true;
      treesitter.nixGrammars = true;
      comment-nvim.enable = true;
      lualine = {
        enable = true;
        theme = "gruvbox-material";
      };
      intellitab.enable = true;
      nix.enable = true;
      bufferline.enable = true;
      nvim-autopairs.enable = true;
      nvim-tree.enable = true;

      undotree.enable = true;
      surround.enable = true;

      lsp = {
        enable = true;
        servers = {
          rnix-lsp.enable = true;
          clangd.enable = true;
        };
      };
      coq-nvim = {
        enable = false; # TODO: This is broken :(
        installArtifacts = true;
        autoStart = "shut-up";
      };
    };

    colorschemes.gruvbox = {
      enable = true;
      contrastDark = "hard";
    };

    options = {
      mouse = "a";
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      number = true;
      wrap = true;
      linebreak = true;
    };

    globals.mapleader = " ";

    maps.normal = {
      "<leader>t" = "<CMD>NvimTreeToggle<CR>";
      "j" = "gj";
      "k" = "gk";
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vscode.cpptools
    ];
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
  };

  # programs.kitty = {
  #   enable = true;
  # };

  nixpkgs.config.allowUnfree = true;
}
