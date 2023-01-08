{ pkgs, lib, ... }:
let
  yeelight = {
    devices."192.168.1.86" = {
      name = "Luz teto";
    };
  };

  config = pkgs.writeTextFile {
    name = "configuration.yaml";
    text = ''
      default_config:

      http:
        server_port: 8123
        use_x_forwarded_for: true
        trusted_proxies: 
          - ::1
          - 127.0.0.1
          - 0.0.0.0

      frontend:
        themes: !include_dir_merge_named themes

      tts:
        - platform: google_translate

      automation: !include automations.yaml
      script: !include scripts.yaml
      scene: !include scenes.yaml

      yeelight: ${builtins.toJSON yeelight}
    '';
  };
in
{
  # Do it this way otherwise it'll take forever to build
  virtualisation.oci-containers = {
    backend = "docker";
    containers.homeassistant = {
      volumes = [
        "${config}:/config/configuration.yaml"
        "/docker/home-assistant:/config"
      ];
      environment.TZ = "Europe/Lisbon";
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        "--network=host"
      ];
    };

    containers.mqtt = {
      image = "eclipse-mosquitto:2.0";
      volumes = [ "mosquitto:/mosquitto" ];
      ports = [ "1883:1883" "9001:9001" ];
      cmd = [ "mosquitto" "-c" "/mosquitto-no-auth.conf" ];
    };
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = true;
      permit_join = false;
      serial.port = "/dev/ttyACM0";
      frontend = true;
      mqtt.server = "mqtt://localhost:1883";
      mqtt.base_topic = "zigbee2mqtt";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."pie" = {
      forceSSL = false;
      enableACME = false;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://localhost:8123";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 8123 8080 ];
}
