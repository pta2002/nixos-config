{ ... }: {
  programs.git = {
    enable = true;
    userName = "Pedro Alves";
    userEmail = "pta2002@pta2002.com";
    extraConfig = {
      init.defaultBranch = "main";
      # pull.rebase = true;
      pull.ff = "only";
      diff.colorMoved = "zebra";
      core.autocrlf = "input";
      safe.directory = [ "/home/pta2002/nixos" ];
      rerere.enabled = true;
    };

    includes = [
      {
        condition = "gitdir:~/CTW/";
        path = "~/.config/git/ctwconf";
      }
    ];
  };
}
