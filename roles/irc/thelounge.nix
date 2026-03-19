{ config, ... }:
{
  services.thelounge = {
    enable = true;
    extraConfig.reverseProxy = true;
  };

  proxy.services.thelounge = "localhost:${toString config.services.thelounge.port}";

  common.backups.paths = [ "/var/lib/thelounge" ];
}
