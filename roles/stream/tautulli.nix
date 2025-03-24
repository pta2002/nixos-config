{ config, ... }:
{
  services.tautulli = {
    enable = true;
  };

  proxy.services.tautulli.addr = "localhost:${toString config.services.tautulli.port}";
}
