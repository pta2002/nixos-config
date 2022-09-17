{ pkgs, lib, inputs, ... }:
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
    godot
    flutter

    # Utilities
    ripgrep
    fd
    exa
    any-nix-shell
    unzip
    zip
    libqalculate
    httpie
    jq
    gh
    floating-print
    zbar
    gnupg

    # Random programs
    discord
    spotify
    texmacs
    lyx
    minecraft
    # visual-paradigm
    calibre
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

    (picom.overrideAttrs (old: {
      src = inputs.picom;
    }))

    # freecad
    mindustry
    reaper
    bottles
    lutris
    # freecad
    google-chrome

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

    sxhkd
    eww
    feh
    playerctl
    maim
    xclip
    inputs.eww-scripts.packages."${pkgs.system}".nm-follow

    (stdenv.mkDerivation rec {
      pname = "phosphor-icons";
      version = "1.4.0";

      ttf = ''${inputs.phosphor-icons}/src/fonts/Phosphor.ttf'';

      dontUnpack = true;

      buildPhase = "";
      installPhase =
        ''
          install -m 644 -D ${ttf} $out/share/fonts/truetype/Phosphor.ttf
        '';
    })
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
      set -Ua fish_user_paths ~/.pub-cache/bin
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
      {
        name = "autopair-fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "1222311994a0730e53d8e922a759eeda815fcb62";
          sha256 = "0lxfy17r087q1lhaz5rivnklb74ky448llniagkz8fy393d8k9cp";
        };
      }
    ];
  };

  programs.direnv.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
    };

    enableFishIntegration = true;
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

  # services.picom = {
  #   enable = true;
  #   experimentalBackends = true;
  #
  #   shadow = true;
  #   shadowExclude = [ "window_type *= 'menu'" ];
  #   backend = "glx";
  #   vSync = true;
  # };

  # xdg.configFile."picom/picom.conf".text = ''
  #   shadow = true
  #   shadow-opacity = 0.3
  # '';

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 12;
    };

    extraConfig = ''
      background_opacity 0.9
      window_padding_width 4
    '';
  };

  programs.rofi.enable = true;

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    # cursorTheme = {
    #   package = pkgs.gnome3.defaultIconTheme;
    #   name = "Adwaita";
    # };
  };

  # cursor theme
  home.file.".icons/default".source = "${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita";

  nixpkgs.config.allowUnfree = true;
}
