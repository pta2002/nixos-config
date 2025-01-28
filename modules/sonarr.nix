{ config, pkgs, ... }:
let
  user = config.services.deluge.user;
  group = config.services.deluge.group;
in
{
  environment.systemPackages = [ pkgs.cross-seed ];

  systemd.services.cross-seed = {
    description = "cross-seed";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cross-seed}/bin/cross-seed daemon";
      User = user;
      Group = group;
    };
  };

  services.autobrr = {
    enable = true;
    secretFile = "/var/lib/autobrr/secret";
    settings.host = "0.0.0.0";
  };

  services.sonarr = {
    enable = true;
    inherit user group;
  };

  services.radarr = {
    enable = true;
    inherit user group;
  };

  services.jackett = {
    enable = true;
  };

  services.cloudflared.tunnels.mars = {
    ingress."sonarr.pta2002.com" = "http://localhost:8989";
    ingress."radarr.pta2002.com" = "http://localhost:7878";
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
