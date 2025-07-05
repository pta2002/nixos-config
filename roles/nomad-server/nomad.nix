{
  pkgs,
  config,
  lib,
  ...
}:
{
  virtualisation.podman.enable = true;

  services.nomad = {
    enable = true;
    extraSettingsPlugins = [ pkgs.nomad-driver-podman ];
    # For now, because it's breaking allocation
    dropPrivileges = false;
    enableDocker = true;
    settings = rec {
      bind_addr = config.proxy.ipv4;
      datacenter = if config.networking.hostName == "cloudy" then "dc-cloud" else "dc-home";
      region = if datacenter == "dc-cloud" then "cloud" else "home";

      # Assume 8GHz total for the cloudy machine
      client.cpu_total_compute = lib.mkIf (datacenter == "dc-cloud") 8000;

      client.enabled = true;
      server.enabled = true;
      server.bootstrap_expect = if datacenter == "dc-home" then 3 else 1;
      server.server_join.retry_join = lib.mkIf (region == "home") [
        "100.86.136.44"
      ];
      plugin = [
        {
          nomad-driver-podman.config = { };
        }
      ];
    };
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
    allowedTCPPorts = [
      4646
      4647
      4648
    ];
    allowedUDPPorts = [ 4646 ];
  };

  environment.systemPackages = with pkgs; [
    damon
  ];
}
