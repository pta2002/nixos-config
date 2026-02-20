{
  networking.networkmanager.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;

    extraSetFlags = [
      "--accept-routes"
    ];
  };
}
