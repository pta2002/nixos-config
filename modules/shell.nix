{ pkgs, ... }:
{
  home.packages = with pkgs; [ any-nix-shell fzf eza bat ripgrep fd ];

  # systemd.user.sessionVariables.EDITOR = "nvim";

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      any-nix-shell fish | source
      base16-gruvbox-dark-hard
      set -x PROJECT_PATHS ~/Projects ~/sources
      set -Ua fish_user_paths ~/.pub-cache/bin
      export EDITOR=nvim
    '';

    shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      g = "git";
      gp = "git push";
      gc = "git commit";
      gpl = "git pull";

      ls = "eza";
      l = "eza -l";
      tree = "eza -T";

      # cat = "bat";
    };

    plugins = with pkgs.fishPlugins; [
      {
        name = "fzf-fish";
        src = fzf-fish.src;
      }
      {
        name = "base16-fish";
        src = pkgs.fetchFromGitHub {
          owner = "tomyun";
          repo = "base16-fish";
          rev = "2f6dd973a9075dabccd26f1cded09508180bf5fe";
          sha256 = "sha256-PebymhVYbL8trDVVXxCvZgc0S5VxI7I1Hv4RMSquTpA=";
        };
      }
      {
        name = "plugin-pj";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pj";
          rev = "43c94f24fd53a55cb6b01400b9b39eb3b6ed7e4e";
          sha256 = "1z65m3w5fi3wfyfiflj9ycndimg3pnh318iv7q9jggybc7kkz1zz";
        };
      }
      {
        name = "colored-man-pages";
        src = colored-man-pages.src;
      }
      {
        name = "autopair-fish";
        src = autopair.src;
      }
      {
        name = "nvm.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "c69e5d1017b21bcfca8f42c93c7e89fff6141a8a";
          sha256 = "084wvdinas1d7v3da16lim7s8asimh389frmfamr7q70fy44spid";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$hostname$directory$git_branch$git_status$character";
      hostname = {
        ssh_only = true;
        format = "[\\($hostname\\)]($style) ";
        style = "bold dimmed blue";
      };
    };

    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  services.ssh-agent.enable = true;
}
