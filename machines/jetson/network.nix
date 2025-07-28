{
  imports = [ ../../modules/proxy.nix ];
  services.tailscale.enable = true;

  proxy.ipv4 = "100.74.251.44";
}
