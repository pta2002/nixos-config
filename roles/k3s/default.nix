{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode=640"
      "--write-kubeconfig-group=k3s"
    ];
  };

  users.groups.k3s = { };
  users.users.pta2002.extraGroups = [ "k3s" ];

  networking.firewall.allowedTCPPorts = [
    6443
  ];
  # networking.firewall.checkReversePath = false;
  networking.firewall.trustedInterfaces = [
    "cni0"
    "flannel.1"
  ];

  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 10.42.0.0/16 -j ACCEPT
    iptables -A INPUT -s 10.43.0.0/16 -j ACCEPT
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -s 10.42.0.0/16 -j ACCEPT || true
    iptables -D INPUT -s 10.43.0.0/16 -j ACCEPT || true
  '';

    # Kernel modules for container networking
  boot.kernelModules = [
    "br_netfilter" "overlay" "ip_vs" "ip_vs_rr" 
    "ip_vs_wrr" "ip_vs_sh" "nf_conntrack"
  ];
}
