# Config file for common home manager
{ pkgs, lib, inputs, config, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./modules/shell.nix
    ./modules/git.nix
    ./modules/tiny.nix
    ./modules/nvim.nix
    ./modules/rice.nix
    ./modules/gnome.nix

    inputs.nix-index-database.hmModules.nix-index

    inputs.android-nixpkgs.hmModules.android
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
    # texlive.combined.scheme-full
    nodejs
    python3
    zig
    zls
    godot3
    flutter
    go
    cmake
    ninja
    janet

    # Utilities
    pciutils
    ripgrep
    fd
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
    gnome.eog
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
    # visual-paradigm
    calibre
    libreoffice
    # obsidian
    zoom-us
    krita
    virt-manager
    qbittorrent
    slack
    xournal
    element-desktop
    plex-media-player
    # todoist-electron

    # freecad
    reaper
    bottles
    lutris
    # freecad
    google-chrome
    notion-app-enhanced
    # blender
    zotero

    # IDEs
    jetbrains.idea-ultimate
    jetbrains.clion
    # emacsUnstable
    # (emacsWithPackagesFromUsePackage {
    #   config = /home/pta2002/.emacs.d/init.el;
    #   package = emacsUnstable;
    #   alwaysEnsure = true;
    # })
    # android-studio

    # Libraries and stuff
    sqlite
    cachix
    nix-prefetch-git
    nurl
    docker-compose

    inputs.devenv.packages.${pkgs.system}.devenv
    android-studio

    # nixgl.auto.nixVulkanNvidia
    # nixgl.nixVulkanIntel
    # nixgl.auto.nixGLDefault
    # nixgl.auto.nixGLNvidiaBumblebee
  ];

  # This is just for parinfer-rust-mode
  home.file.".emacs.d/parinfer-rust-mode".source = pkgs.parinfer-rust;

  home.sessionVariables = {
    EDITOR = "nvim";
    MOZ_USE_XINPUT2 = "true";
  };

  programs.firefox.enable = true;

  programs.direnv.enable = true;
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

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

  android-sdk.enable = false;
  android-sdk.packages = sdkPkgs: with sdkPkgs; [
    build-tools-33-0-0
    cmdline-tools-latest
    platform-tools
    platforms-android-33
    sources-android-33
    emulator
    tools
  ];
  android-sdk.path = "${config.home.homeDirectory}/.local/share/android";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      "text/plain" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "image/jpeg" = [ "org.gnome.eog.desktop" ];
      "image/png" = [ "org.gnome.eog.desktop" ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  home.file.".ideavimrc".text = ''
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'vim-matchit'
  '';

  nixpkgs.config.permittedInsecurePackages = [ "nodejs-16.20.0" ];
}
