{ inputs, ... }: { pkgs, config, ... }:
{
  home.packages = with pkgs; [
    sxhkd
    eww
    feh
    playerctl
    maim
    xclip
    pamixer
    inputs.eww-scripts.packages."${pkgs.system}".follows
    inputs.eww-scripts.packages."${pkgs.system}".upower-follow
    inputs.eww-scripts.packages."${pkgs.system}".pa-follow

    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })

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

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono";
      size = 12;
    };

    extraConfig = ''
      background_opacity 0.9
      window_padding_width 4
      confirm_os_window_close 0
    '';
  };

  programs.rofi.enable = true;

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  services.picom = {
    enable = true;
    package = pkgs.picom.overrideAttrs (old: {
      src = inputs.picom;
    });

    backend = "glx";
    experimentalBackends = true;

    shadow = true;
    shadowOpacity = 1.0;

    settings = {
      blur-background = true;
      blur-method = "dual_kawase";
      blur-strength = 5;
      blur-background-exclude = [ "name ~= 'slop'" ];

      fading = true;
      fade-delta = 3;

      round-borders = 1;
      corner-radius = 12.0;
    };

    wintypes = {
      desktop = { shadow = true; };
      dropdown_menu = { shadow = false; blur = false; full-shadow = false; opacity = 1.0; };
      popup_menu = { shadow = false; blur = false; full-shadow = false; opacity = 1.0; };
      menu = { shadow = false; blur = false; full-shadow = false; opacity = 1.0; };
      tooltip = { shadow = false; blur = true; full-shadow = false; opacity = 1.0; };
    };
  };

  home.file =
    let
      ln = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      # cursor theme
      ".icons/default".source = "${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita";

      ".config/bspwm".source = ln "/home/pta2002/nixos/configs/bspwm";
      ".config/sxhkd".source = ln "/home/pta2002/nixos/configs/sxhkd";
      ".config/eww".source = ln "/home/pta2002/nixos/configs/eww";
    };
}
