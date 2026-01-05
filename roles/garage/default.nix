{ pkgs, config, ... }:
{
  age.secrets = {
    garage = {
      rekeyFile = ../../secrets/garage.age;
      generator.script =
        { lib, pkgs, ... }:
        ''
          echo "GARAGE_RPC_SECRET=$(${lib.getExe pkgs.openssl} rand -hex 32)"
          echo "GARAGE_ADMIN_TOKEN=$(${lib.getExe pkgs.openssl} rand -hex 32)"
          echo "GARAGE_METRICS_TOKEN=$(${lib.getExe pkgs.openssl} rand -hex 32)"
        '';
    };
  };

  services.garage = {
    enable = true;
    package = pkgs.garage_2;

    environmentFile = config.age.secrets.garage.path;

    settings = {
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "127.0.0.1:3901";
      replication_factor = 1;

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage.localhost";
      };

      kv2_api.api_bind_addr = "[::]:3904";
    };
  };

  proxy.services.garage = "localhost:3900";
}
