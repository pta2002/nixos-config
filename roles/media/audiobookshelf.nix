{ config, ... }:
{
  services.audiobookshelf = {
    # enable = true;
    port = 8232;
  };

  # services.cloudflared.tunnels.mars.ingress."audiobooks.pta2002.com" = "http://localhost:${toString config.services.audiobookshelf.port}";
  # proxy.services.audiobooks = "localhost:${toString config.services.audiobookshelf.port}";
  #
  # common.backups.paths = [ "/var/lib/audiobookshelf" ];
}
