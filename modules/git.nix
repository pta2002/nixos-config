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
      push.autoSetupRemote = true;

      # Log here
      alias.hlog = "log --oneline --graph -- .";
      alias.glog = "log --oneline --graph";
      alias.rbs = "rebase -i --autosquash";
      alias.rbi = "rebase -i";
      alias.rb = "rebase";
      alias.ps = "push";
      alias.fps = "push --force-with-lease";
      alias.aa = "add -A";
      alias.s = "status";
      alias.cm = "commit";
    };
  };
}
