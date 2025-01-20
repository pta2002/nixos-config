{ pkgs, config, ... }:
{
  services.sonarr = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.radarr = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.readarr = {
    enable = true;
    user = "transmission";
    group = "transmission";
  };

  services.jackett = {
    enable = true;
  };

  services.cloudflared.tunnels.mars = {
    ingress."sonarr.pta2002.com" = "http://localhost:8989";
    ingress."radarr.pta2002.com" = "http://localhost:7878";
    ingress."readarr.pta2002.com" = "http://localhost:8787";
    ingress."jackett.pta2002.com" = "http://localhost:9117";
    ingress."overseerr.pta2002.com" = "http://localhost:5055";
  };

  services.jellyseerr.enable = true;

  # Remove when https://github.com/NixOS/nixpkgs/issues/360592 is done
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];
}
