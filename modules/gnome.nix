{ pkgs, ... }:
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

      "org/gnome/shell".disable-user-extensions = false;
      "org/gnome/shell".enabled-extensions = [
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "caffeine@patapon.info"
        "tiling-assistant@leleat-on-github"
      ];
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    caffeine
    bluetooth-quick-connect
    tiling-assistant
  ];
}
