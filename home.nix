{ inputs, ... }@args: { pkgs, lib, ... }:
{
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    (import ./modules/rice.nix args)
  ];

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
    unzip
    zip
    libqalculate
    httpie
    jq
    gh
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

    # freecad
    mindustry
    reaper
    bottles
    lutris
    # freecad
    google-chrome

    # IDEs
    jetbrains.idea-ultimate
    jetbrains.clion
    android-studio

    # Libraries and stuff
    sqlite
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.firefox.enable = true;

  programs.direnv.enable = true;

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

  nixpkgs.config.allowUnfree = true;
}
