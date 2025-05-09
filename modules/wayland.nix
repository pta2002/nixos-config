{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = lib.mkIf (config.services.xserver.desktopManager.gnome.enable == false) [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs.xwayland.enable = true;

  environment.sessionVariables = rec {
    _JAVA_AWT_WM_NONREPARENTING = "1";

    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    MOZ_ENABLE_WAYLAND = "1";

    WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.systemPackages = [
    pkgs.wl-clipboard
  ];

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # This is because swaylock only works this way
  security.pam.services.swaylock = { };
}
