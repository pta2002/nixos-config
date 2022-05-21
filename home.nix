{ pkgs, lib, ... }:
{
  home.stateVersion = "21.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Programming languages
    gcc
    gnumake
    jdk17
    maven
    texlive.combined.scheme-full
    nodejs
    python3
    zig
    zls

    # Utilities
    ripgrep
    fd
    exa
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
    # calibre
    signal-desktop
    tdesktop
    zotero
    libreoffice
    obsidian
    zoom-us
    krita
    musescore
    virt-manager
    gnome3.gnome-terminal
    qbittorrent
    spot

    # IDEs
    jetbrains.idea-ultimate
    jetbrains.datagrip
    jetbrains.clion
    android-studio

    # Libraries and stuff
    sqlite

    # Random things like fonts
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
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
      safe.directory = [ "/home/pta2002/nixos" ];
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      any-nix-shell fish | source
      base16-gruvbox-dark-hard
      set -x PROJECT_PATHS ~/Projects ~/sources
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
      {
        name = "plugin-pj";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pj";
          rev = "43c94f24fd53a55cb6b01400b9b39eb3b6ed7e4e";
          sha256 = "1z65m3w5fi3wfyfiflj9ycndimg3pnh318iv7q9jggybc7kkz1zz";
        };
      }
      {
        name = "colored-man-pages";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "colored_man_pages.fish";
          rev = "f885c2507128b70d6c41b043070a8f399988bc7a";
          sha256 = "0ifqdbaw09hd1ai0ykhxl8735fcsm0x2fwfzsk7my2z52ds60bwa";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
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
      treesitter.nixGrammars = false;
      treesitter.ensureInstalled = "all";
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
          zls.enable = true;
          pyright.enable = true;
        };

        onAttach = ''
          vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
        '';
      };

      coq-nvim = {
        enable = false; # TODO: This is broken :(
        installArtifacts = true;
        autoStart = "shut-up";
      };

      zig.enable = true;
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

    extraPlugins = with pkgs.vimPlugins; [
      vim-sleuth
    ];
    extraPackages = [ pkgs.xclip ];
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
