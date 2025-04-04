{ pkgs, my-switches, ... }:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraPackages =
      p: with p; [
        gtts
      ];

    extraComponents = [
      "esphome"
      "met"
      "cast"
      "spotify"
      "plex"
      "sonarr"
      "radarr"
      "transmission"
      "tasmota"
      "matter"
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
      mini-graph-card
      mini-media-player
      hourly-weather
      bubble-card
    ];

    lovelaceConfig = {
      title = "Home";
      views = [
        {
          title = "Dashboard";
          cards = [
            {
              type = "vertical-stack";
              title = "Bedroom";
              cards = [
                {
                  type = "horizontal-stack";
                  cards = [
                    {
                      type = "custom:mushroom-light-card";
                      entity = "light.ceiling_light";
                      fill_container = true;
                      layout = "vertical";
                      show_brightness_control = true;
                      name = "Ceiling";
                    }
                    {
                      type = "custom:mushroom-light-card";
                      entity = "light.bed_light";
                      fill_container = true;
                      layout = "vertical";
                      show_brightness_control = true;
                      name = "Bed";
                    }
                    {
                      type = "custom:mushroom-light-card";
                      entity = "light.desk_light";
                      fill_container = true;
                      layout = "vertical";
                      show_brightness_control = true;
                      name = "Desk";
                    }
                  ];
                }
                {
                  type = "horizontal-stack";
                  cards = [
                    {
                      type = "custom:mushroom-light-card";
                      entity = "light.desk_strip";
                      fill_container = true;
                      layout = "vertical";
                      show_brightness_control = true;
                      name = "Desk strip";
                    }
                    {
                      type = "custom:mushroom-light-card";
                      entity = "light.short_cable_lights";
                      fill_container = true;
                      layout = "vertical";
                      show_brightness_control = true;
                      name = "Bookshelf strip";
                    }
                  ];
                }
                {
                  type = "custom:mini-graph-card";
                  entities = [ "sensor.bedroom_temperature_temperature" ];
                  name = "Temperature";
                  hours_to_show = 12;
                  points_per_hour = 4;
                }
                {
                  type = "custom:mini-media-player";
                  entity = "media_player.spotify";
                  artwork = "material";
                }
              ];
            }
          ];
        }
      ];
    };
    lovelaceConfigWritable = true;

    config = {
      default_config = { };

      homeassistant = {
        name = "Home";
        time_zone = "Europe/Lisbon";
        temperature_unit = "C";
        unit_system = "metric";
      };

      mqtt = { };

      http = {
        use_x_forwarded_for = true;
        cors_allowed_origins = [
          "https://home.pta2002.com"
          "https://home.m.pta2002.com"
          "http://mars:8123"
          "http://192.168.1.112:8123"
        ];
        trusted_proxies = [
          "::1"
          "127.0.0.1"
          "0.0.0.0"
          "172.30.33.0/24"
        ];
      };
    };
  };

  # Web UI is at :8080
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

  services.matter-server = {
    enable = true;
  };

  services.mosquitto = {
    enable = true;
    listeners = [ ];
  };

  services.cloudflared.tunnels.mars = {
    ingress."home.pta2002.com" = "http://localhost:8123";
  };

  proxy.services = {
    home = "localhost:8123";
    zigbee2mqtt = "localhost:8080";
  };

  systemd.services.switches = {
    description = "switches";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${my-switches.packages.${pkgs.system}.default}/bin/my-switches";
      Type = "simple";
      User = "switches";
      Group = "switches";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  users.users.switches = {
    isSystemUser = true;
    group = "switches";
  };

  users.groups.switches = { };

  networking.firewall.allowedTCPPorts = [
    80
    8123
    1883
    9001
  ];

  common.backups.paths = [ "/var/lib/hass" ];
}
