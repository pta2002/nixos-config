{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prowlarr.settings;
  prowlarrCfg = config.services.prowlarr;
  inherit (lib) mkOption types;

  appSubmodule = {
    options = {
      url = mkOption {
        type = types.str;
        description = "URL this application is accessible at";
      };

      apiKeyFile = mkOption {
        type = types.path;
        description = "File containing the API key for this service";
      };
    };
  };

  jsonFormat = pkgs.formats.json { };

  prowlarr-setup = pkgs.python3Packages.buildPythonApplication {
    pname = "prowlarr-setup";
    version = "0.1.0";
    pyproject = false;

    propagatedBuildInputs = with pkgs.python3Packages; [
      rich
      requests
    ];

    dontUnpack = true;
    installPhase = ''
      install -Dm755 "${./prowlarr-setup.py}" "$out/bin/prowlarr-setup"
    '';
  };
in
{
  options.services.prowlarr.settings = {
    url = mkOption {
      type = types.str;
      description = "URL that Prowlarr is accessible at";
    };

    apiKeyFile = mkOption {
      type = types.path;
      description = "Path to the prowlarr API key";
    };

    applications = mkOption {
      type = types.attrsOf (types.submodule appSubmodule);
      default = { };
      description = "Applications to be configured in prowlarr.";
    };
  };

  config = lib.mkIf prowlarrCfg.enable (
    let
      jsonConfig = {
        applications = lib.mapAttrs (k: v: { inherit (v) url; }) cfg.applications;
        inherit (cfg) url;
      };
      configFile = jsonFormat.generate "config.json" jsonConfig;

      putSecrets = pkgs.writeShellScript "put-secrets" (
        let
          apiKeyArgs = lib.concatStringsSep " " (
            [ ''--arg apiKey "$(${config.systemd.package}/bin/systemd-creds cat apiKey)"'' ]
            ++ (lib.mapAttrsToList (
              name: val:
              ''--arg ${name}apiKey "$(${config.systemd.package}/bin/systemd-creds cat ${name}apiKey)"''
            ) cfg.applications)
          );

          apiKeyPipeline = lib.concatStringsSep " | " (
            [ ''.apiKey = $apiKey'' ]
            ++ (lib.mapAttrsToList (
              name: val: ''.applications.${name}.apiKey = ''$${name}apiKey''
            ) cfg.applications)
          );
        in
        ''
          ${lib.getExe pkgs.jq} '${apiKeyPipeline}' ${apiKeyArgs} < '${configFile}' > /run/prowlarr-setup/config.json
        ''
      );
    in
    {
      systemd.services.prowlarr.serviceConfig = {
        # Wait to ensure it is available. There's DEFINITELY a better way to do this, using e.g. systemd-socket-proxyd
        ExecStartPost = pkgs.writeShellScript "wait-for-prowlarr" ''
          timeout 30 '${lib.getExe pkgs.bash}' -c 'while ! ${lib.getExe pkgs.curl} --fail http://localhost:9696 -L --silent > /dev/null; do sleep 1; done'
        '';
      };

      systemd.services.prowlarr-setup = {
        description = "Set up prowlarr";
        requires = [ "prowlarr.service" ];
        after = [ "prowlarr.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          DynamicUser = true;
          Type = "oneshot";

          LoadCredential = [
            "apiKey:${cfg.apiKeyFile}"
          ] ++ (lib.mapAttrsToList (name: val: ''${name}apiKey:${val.apiKeyFile}'') cfg.applications);

          RuntimeDirectory = [ "prowlarr-setup" ];

          ExecStartPre = putSecrets;
          ExecStart = ''
            ${prowlarr-setup}/bin/prowlarr-setup /run/prowlarr-setup/config.json
          '';
        };
      };
    }
  );
}
