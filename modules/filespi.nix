{ pkgs, ... }: {
  virtualisation.oci-containers.containers.filestash = {
    image = "machines/filestash";
    ports = [ "8334:8334" ];

    environment = {
      APPLICATION_URL = "https://filestash.pta2002.com";
    };
  };

  services.argoWeb = {
    ingress."filestash.pta2002.com" = "http://localhost:8334";
  };
}
