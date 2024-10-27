{ pkgs, my-switches, ... }:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraPackages = p: with p; [
      gtts
    ];

    extraComponents = [ "esphome" "met" ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mushroom
    ];

    lovelaceConfig = {
      title = "Home";
      views = [{
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
                    entity = "light.short_cable_lights_2";
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
            ];
          }
        ];
      }];
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

      mqtt = {
        # Home assistant decided that they want to make you jump through hoops to set up this kind of thing...:w
        # Why? I have absolutely no idea. But I hope one of these days I can
        # move to something that actually respects me...

        # broker = "localhost";
        # port = 1883;
        # discovery = true;
      };

      http = {
        use_x_forwarded_for = true;
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

  services.mosquitto = {
    enable = true;
    listeners = [ ];
  };

  services.cloudflared.tunnels.mars = {
    ingress."home.pta2002.com" = "http://localhost:8123";
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
    8080
    1883
    9001
  ];
}
