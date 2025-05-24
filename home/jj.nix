{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "pta2002@pta2002.com";
        name = "Pedro Alves";
      };

      ui.default-command = "log";

      # So we don't need to always specify --allow-all
      git.push-new-bookmarks = true;

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };

      aliases = {
        # Pull the closest bookmark up
        tug = [
          "bookmark"
          "move"
          "--from"
          "closest_bookmark(@-)"
          "--to"
          "@-"
        ];
        c = [ "commit" ];
        e = [ "edit" ];
        r = [ "rebase" ];
        s = [ "squash" ];
        si = [
          "squash"
          "--interactive"
        ];
      };
    };
  };
}
