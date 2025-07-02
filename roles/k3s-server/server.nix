{ config, pkgs, ... }:
{
  age.secrets.k3s-token.rekeyFile = ../../secrets/k3s.age;
  age.secrets.k3s-tailscale.rekeyFile = ../../secrets/k3s-tailscale.age;

  # For VPN connection between machines
  services.tailscale.enable = true;

  networking.firewall.allowedTCPPorts = [
    6443 # API server
    2379 # etcd
    2380 # etcd
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # multi-node networking
  ];

  services.k3s = {
    enable = true;
    clusterInit = false;
    serverAddr = "https://panda:6443";

    role = "server";
    tokenFile = config.age.secrets.k3s-token.path;
    extraFlags = [
      "--write-kubeconfig-group=k3s"
      "--write-kubeconfig-mode=640"
      "--vpn-auth-file=${config.age.secrets.k3s-tailscale.path}"
    ];
  };

  systemd.services.k3s.path = [ pkgs.tailscale ];

  users.groups.k3s = { };
  users.users.pta2002.extraGroups = [ "k3s" ];
}
