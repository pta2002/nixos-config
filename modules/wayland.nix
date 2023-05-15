{ inputs, pkgs, ... }: {
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.xwayland.enable = true;

  environment.sessionVariables = rec {
    _JAVA_AWT_WM_NONREPARENTING = "1";

    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = false;
    };
  };

  environment.systemPackages = [
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    pkgs.wl-clipboard
  ];

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
}
