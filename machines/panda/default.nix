{ pkgs, config, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    nh
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
