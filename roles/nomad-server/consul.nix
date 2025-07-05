{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.consul = {
    enable = true;
    webUi = true;

    interface.advertise = config.services.tailscale.interfaceName;

    extraConfig = rec {
      datacenter = if config.networking.hostName == "cloudy" then "dc-cloud" else "dc-home";
      bind_addr = config.proxy.ipv4;
      server = true;
      client_addr = "0.0.0.0";
      retry_join = lib.mkIf (datacenter == "dc-home") [
        "100.81.36.57" # panda
        "100.74.251.44" # jetson
      ];
      connect.enabled = true;

      retry_join_wan = lib.mkIf (datacenter == "dc-home") [
        "100.86.136.44" # cloudy
      ];

      bootstrap_expect = lib.mkIf (datacenter == "dc-cloud") 1;
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
    allowedTCPPorts = [
      8300
      8301
      8302
      8500
    ];
    allowedUDPPorts = [
      8301
      8302
    ];
  };

  environment.systemPackages = with pkgs; [
    damon
  ];
}
