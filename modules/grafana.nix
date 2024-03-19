{ config, pkgs, ... }:
{
  services.grafana = {
    enable = true;
    domain = "grafana.pta2002.com";
    settings.server.http_port = 2342;
    addr = "127.0.0.1";
  };

  services.argoWeb.ingress."grafana.pta2002.com" = "http://127.0.0.1:${builtins.toString config.services.grafana.settings.server.http_port}";
}
