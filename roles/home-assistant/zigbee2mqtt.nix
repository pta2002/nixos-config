{
  # Web UI is at :8080
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant.enable = true;
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

  networking.firewall.allowedTCPPorts = [ 1883 ];

  proxy.services.zigbee2mqtt = "localhost:8080";
}
