{ pkgs, ... }: {
  imports = [
    ./argoweb.nix
  ];

  # services.plex = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.argoWeb = {
  #   ingress."plex.pta2002.com" = "http://localhost:32400";
  # };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.plex = {
      image = "linuxserver/plex";
      extraOptions = [ "--network=host" ];
      volumes = [
        "/var/lib/transmission:/movies"
        "library:/config"
      ];
    };
  };

  networking.firewall.enable = false;
}
