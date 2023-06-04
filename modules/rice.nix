{ pkgs, config, inputs, hostname, ... }:
{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  xsession.enable = true;

  home.packages = with pkgs; [
    feh
    playerctl
    maim
    xclip
    pamixer
    xdotool
    brightnessctl
    inputs.eww-scripts.packages."${pkgs.system}".follows
    inputs.eww-scripts.packages."${pkgs.system}".upower-follow
    inputs.eww-scripts.packages."${pkgs.system}".pa-follow
    inputs.eww-scripts.packages."${pkgs.system}".hypr-follow
    eww-wayland
    swaylock-effects

    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })

    (pkgs.rofi.override {
      plugins = with pkgs; [ rofi-emoji rofi-calc ];
    })

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

    hyprpaper
  ];

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    extraConfig = ''
      background_opacity 0.9
      window_padding_width 4
      confirm_os_window_close 0
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "12x10";
        transparency = 30;
        background = "#1F1F28";
        corner_radius = 12;

        idle_threshold = "10m";
        timeout = "10s";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # TODO: This isn't working for some reason
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      package = pkgs.adwaita-qt;
      name = "Adwaita-dark";
    };
  };

  services.picom = {
    enable = true;

    backend = "glx";

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
      dialog = { animation = false; };
    };
  };

  xsession.windowManager.bspwm = {
    enable = false;

    extraConfigEarly = ''
      pgrep -x sxhkd > /dev/null || sxhkd &

      # TODO: Iterate over all monitors
      if [[ $(hostname) == "hydrogen" ]]; then
        bspc monitor DVI-I-0 -d 1 2 3 4 5 6 7 8 9 10
        bspc monitor HDMI-0 -d 1 2 3 4 5 6 7 8 9 10
        eww open bar-desktop-1 &
        eww open bar-desktop-2 &
      else
        bspc monitor -d 1 2 3 4 5 6 7 8 9 10
        eww open bar-laptop &
      fi
    '';

    settings = {
      border_width = 2;
      window_gap = 12;
      split_ratio = 0.52;
      borderless_monocle = true;
      gapless_monocle = false;
      focus_follows_pointer = true;
    };

    rules."*:*:Picture-in-Picture" = {
      state = "floating";
      sticky = true;
    };

    rules."Zathura".state = "tiled";

    startupPrograms = [
      "feh --bg-fill ~/.config/wallpaper.jpg"
      "xsetroot -cursor_name left_ptr"
    ];
  };

  services.swayidle =
    let
      cmd = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --effect-blur 10x7 --fade-in 0.2 --grace 1";
    in
    {
      enable = true;
      events = [{
        event = "before-sleep";
        command = cmd;
      }];
      timeouts = [{
        timeout = 300;
        command = cmd;
      }];
    };

  home.file =
    let
      ln = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      # cursor theme
      ".icons/default".source = "${pkgs.gnome.adwaita-icon-theme}/share/icons/Adwaita";

      ".config/wallpaper.jpg".source = ../wallpaper.jpg;
      ".config/sxhkd".source = ln "/home/pta2002/nixos/configs/sxhkd";
      ".config/eww".source = ln "/home/pta2002/nixos/configs/eww";
      ".config/rofi/config.rasi".source = ../configs/rofi.rasi;
      ".config/hypr/hyprland.conf".source = ln "/home/pta2002/nixos/configs/hypr/hyprland.conf";
      ".config/hypr/hyprpaper.conf".source = ln "/home/pta2002/nixos/configs/hypr/hyprpaper.conf";
      ".config/hypr/machine.conf".source = ../configs/hypr/${hostname}.conf;
    };
}
