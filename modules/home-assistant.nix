{ pkgs, my-switches, ... }:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraPackages = p: with p; [
      gtts
    ];

    extraComponents = [ "esphome" "met" ];

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
