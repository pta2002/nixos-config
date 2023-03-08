{ inputs, ... }@args: { pkgs, lib, ... }:
{
  imports = [
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/tiny.nix
    (import ./modules/rice.nix args)
  ];

  home.stateVersion = "21.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Programming languages
    gcc
    gdb
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
    go

    # Utilities
    pciutils
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
    wget
    ffmpeg
    htop
    gnome.nautilus
    dnsutils
    usbutils
    pciutils
    brightnessctl
    imagemagick
    yt-dlp
    weechat

    # Random programs
    (discord.override {
      nss = nss_latest;
      withOpenASAR = true;
    })

    spotify
    texmacs
    lyx
    minecraft
    # visual-paradigm
    calibre
    signal-desktop
    tdesktop
    zotero
    # libreoffice
    obsidian
    zoom-us
    krita
    musescore
    virt-manager
    qbittorrent
    spot
    slack
    emacs
    gnome.pomodoro
    xournal
    element-desktop
    todoist-electron

    # freecad
    mindustry
    reaper
    bottles
    lutris
    # freecad
    google-chrome
    notion-app-enhanced

    # IDEs
    jetbrains.idea-ultimate
    jetbrains.clion
    # android-studio

    # Libraries and stuff
    sqlite
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MOZ_USE_XINPUT2 = "true";
  };

  programs.firefox.enable = true;

  programs.direnv.enable = true;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vscode.cpptools
      github.copilot
      ms-toolsai.jupyter
    ];
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
  };

  programs.zathura = {
    enable = true;

    mappings = {
      "b" = "toggle_statusbar";
      "i" = "set recolor";
      "f" = "toggle_fullscreen";
    };

    options = {
      "selection-clipboard" = "clipboard";
      "guioptions" = "";
      "recolor-lightcolor" = "rgba(29,32,33,0)";
      "default-bg" = "rgba(29,32,33,0.8)";
      "recolor-keephue" = true;
      recolor = true;
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      vo = "gpu";
      hwdec = "auto-safe";
    };
  };

  services.mpris-proxy.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "text/plain" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
