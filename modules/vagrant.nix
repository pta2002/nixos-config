# Enables vagrant
{ pkgs, ... }: {
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "pta2002" ];
  environment.systemPackages = [ pkgs.vagrant ];
}
