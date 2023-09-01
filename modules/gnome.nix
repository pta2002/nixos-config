{ lib, ... }:
with lib.hm.gvariant;
{
  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = true;
      };
    };
  };
}
