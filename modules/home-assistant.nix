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
  sensorPython = pkgs.python3.withPackages (ps: with ps; [
    termcolor
    paho-mqtt
    psutil
    pytz
    pyyaml
    rpi-bad-power
  ]);

  system-sensors = pkgs.stdenv.mkDerivation {
    pname = "system-sensors";
    version = "master";

    src = pkgs.fetchFromGitHub {
      owner = "Sennevds";
      repo = "system_sensors";
      rev = "57121335542abbaa1346c02a5dfa307fbed176a9";
      sha256 = "02rp4w3nrablrhg99l25qb4642w0k7842jx877zvz60jnsff6m9l";
    };

    buildInputs = with pkgs; [
      bash
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp -r $src/src $out/src
      cat > $out/bin/system-sensors-unwrapped <<EOF
      #!/usr/bin/env bash
      exec ${sensorPython}/bin/python3 $out/src/system_sensors.py \$@
      EOF
      chmod +x $out/bin/system-sensors-unwrapped
      makeWrapper $out/bin/system-sensors-unwrapped $out/bin/system-sensors
    '';
  };

  sensorConfig = pkgs.writeText "settings.yml" ''
    mqtt:
      hostname: 127.0.0.1
      port: 1883 #defaults to 1883
    deviceName: pie
    client_id: pie
    timezone: Europe/Lisbon
    update_interval: 60 #Defaults to 60
    sensors:
      temperature: true
      display: true
      clock_speed: true
      disk_use: true
      memory_use: true
      cpu_usage: true
      load_1m: true
      load_5m: true
      load_15m: true
      net_tx: true
      net_rx: true
      swap_usage: true
      power_status: true
      last_boot: true
      hostname: true
      host_ip: true
      host_os: true
      host_arch: true
      last_message: true
      updates: true
      wifi_strength: true
      wifi_ssid: true
      external_drives:
        # Only add mounted drives here, e.g.:
        # Drive1: /media/storage
  '';
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

  systemd.services.sensors = {
    description = "sensors";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${system-sensors}/bin/system-sensors ${sensorConfig}";
      Type = "simple";
      User = "sensors";
      Group = "sensors";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  users.users.sensors = {
    home = "/var/lib/sensors";
    createHome = true;
    isSystemUser = true;
    group = "sensors";
  };

  users.groups.sensors = { };

  networking.firewall.allowedTCPPorts = [ 80 8123 8080 ];
}
