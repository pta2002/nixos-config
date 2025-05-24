{ lib, ... }:
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

  programs.starship.settings = {
    format = lib.mkForce ''$hostname$directory''${custom.git_branch}''${custom.git_state}''${custom.jj}$character'';

    custom.jj = {
      ignore_timeout = true;
      description = "current jj status";
      symbol = "";
      when = true;
      command = ''
        jj root > /dev/null && jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
          separate(" ",
            "🥋",
            change_id.shortest(4),
            bookmarks,
            "|",
            concat(
              if(conflict, "💥"),
              if(divergent, "🚧"),
              if(hidden, "👻"),
              if(immutable, "🔒"),
            ),
            raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
            raw_escape_sequence("\x1b[1;32m") ++ if(description.first_line().len() == 0,
              "(no description set)",
              if(description.first_line().substr(0, 29) == description.first_line(),
                description.first_line(),
                description.first_line().substr(0, 29) ++ "…",
              )
            ) ++ raw_escape_sequence("\x1b[0m"),
          )
        '
      '';
    };

      git_state.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;
      custom.git_branch = {
        when = true;
        command = "jj root --ignore-working-copy >/dev/null 2>&1 || starship module git_branch";
        description = "Only show git_branch if we're not in a jj repo";
      };

      custom.git_state = {
        when = true;
        command = "jj root --ignore-working-copy >/dev/null 2>&1 || starship module git_state";
        description = "Only show git_state if we're not in a jj repo";
      };
  };
}
