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

  # networking.firewall.allowedTCPPorts = [
  #   6443
  # ];
}
