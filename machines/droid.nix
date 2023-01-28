{ pkgs, config, ... }:

{
  environment.packages = with pkgs; [
    openssh
    git
    github-cli
  ];

  user.shell = "${pkgs.fish}/bin/fish";

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "22.05";
}
