{ pkgs, config, ... }: {
  services.quassel.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.quassel.portNumber ];
}
